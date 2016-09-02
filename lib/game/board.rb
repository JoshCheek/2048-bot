require 'game/display_ansi_board'

module Game
  class Board
    def self.[](*rows)
      validate rows
      new rows
    end

    def self.validate(rows)
      rows.length == 4 or raise ArgumentError, "Expected 4 rows, got #{rows.length}"
      rows.each do |row|
        row.length == 4 or raise ArgumentError, "Expected 4 columns, got #{row.length}"
        row.each do |tile|
          Integer === tile or
            raise ArgumentError, "#{tile.inspect} should be an integer (use 0 for empty)"
          next if tile == 0
          next if tile != 1 && (tile == 2**Math.log2(tile).to_i)
          raise ArgumentError, "#{tile.inspect} is not a valid tile value"
        end
      end
    end

    def self.random_start
      rows = 4.times.map { 4.times.map { 0 } }
      2.times { rows[rand 4][rand 4] = [2, 4].sample }
      new rows
    end

    attr_accessor :rows

    def initialize(rows)
      self.rows = rows
    end

    def shift(direction)
      case direction
      when :right then perform_shift rank_type: :row,    increasing: true
      when :left  then perform_shift rank_type: :row,    increasing: false
      when :down  then perform_shift rank_type: :column, increasing: true
      when :up    then perform_shift rank_type: :column, increasing: false
      else raise ArgumentError, "Not a direction: #{direction.inspect}"
      end
    end

    def finished?
      return false if rows.any? { |row| row.any? { |tile| tile == 0 } }
      (0..3).each do |rank|
        (0..2).each do |index|
          curnt = rows[rank][index]
          right = rows[rank][index+1]
          below = rows[index+1][rank]
          return false if curnt == right || curnt == below
        end
      end
      true
    end

    def won?
      rows.any? { |row| row.any? { |tile| tile >= 2048 } }
    end

    def generate_tile
      y, x = INDEXES.select { |y, x| available? y, x }.sample
      return self unless y && x # an optimization
      new_tiles = rows.map.with_index do |row, index|
        next row unless index == y
        row = row.dup
        row[x] = 2
        row
      end
      self.class.new(new_tiles)
    end

    def max_tile
      rows.map { |row| row.max }.max
    end

    def to_a
      rows
    end

    # hash and eql? allow boards to be hash keys,
    # which allow them to be used in a a set,
    # which allow us to call .uniq on an array of them
    def hash
      rows.hash
    end

    def eql?(board)
      rows.eql?(board.rows)
    end

    def ==(board)
      rows == board.rows
    end

    def tiles
      rows.flatten
    end

    def [](y, x)
      rows[y][x] || raise
    rescue
      raise ArgumentError, "Indexes should be from 0 to 3, you requested y:#{y.inspect}, x:#{x.inspect}"
    end

    # really, this isn't the best place for this method,
    # but it's just super convenient for how I'm actually using it
    # (on the fly choices to print)
    def to_s
      DisplayAnsiBoard.call(self)
    end

    def each_row(&block)
      rows.each(&block)
    end

    private

    INDEXES = (0..3).flat_map { |y| (0..3).map { |x| [y, x] } }.map(&:freeze).freeze

    def available?(y, x)
      rows[y][x] == 0
    end

    def perform_shift(rank_type:, increasing:)
      next_rows = rows.map { |row| row.dup }

      if rank_type == :column
        get = -> rank, index        { next_rows[index][rank]         }
        set = -> rank, index, value { next_rows[index][rank] = value }
      elsif rank_type == :row
        get = -> rank, index        { next_rows[rank][index]         }
        set = -> rank, index, value { next_rows[rank][index] = value }
      else
        raise "bug: #{rank_type.inspect} is not :column or :row"
      end

      if increasing
        tos   = 3.downto(0)
        froms = -> to { (to-1).downto(0) }
      else
        tos   = 0.upto(3)
        froms = -> to { (to+1).upto(3) }
      end

      (0..3).each do |rank|
        tos.each do |to|
          froms[to].each do |from|
            to_value   = get[rank, to]
            from_value = get[rank, from]
            if from_value == 0
              # nothing to move
            elsif to_value == 0
              # anything can move to here, and values after it can combine with it
              set[rank, to,   from_value]
              set[rank, from, 0]
            elsif to_value == from_value
              # combine and move onto the next one (only one combination allowed per tile)
              set[rank, to,   to_value + from_value]
              set[rank, from, 0]
              break
            else
              # can't combine and squares after the tile can't move through it
              break
            end
          end
        end
      end
      self.class.new next_rows
    end
  end
end
