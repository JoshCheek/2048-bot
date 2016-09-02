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
  end
end
