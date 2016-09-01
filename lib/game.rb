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
        row.each do |cell|
          Integer === cell or
            raise ArgumentError, "#{cell.inspect} should be an integer (use 0 for empty)"
          next if cell == 0
          next if cell != 1 && (cell == 2**Math.log2(cell).to_i)
          raise ArgumentError, "#{cell.inspect} is not a valid cell value"
        end
      end
    end

    def self.random_start
      rows = 4.times.map { 4.times.map { 0 } }
      2.times { rows[rand 4][rand 4] = (rand < 0.5 ? 2 : 4) }
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
      false # TODO should be smarter
    end

    def generate_tile
      y, x = INDEXES.select { |y, x| available? y, x }.sample
      return self unless y && x # an optimization
      new_cells = rows.map.with_index do |row, index|
        next row unless index == y
        row = row.dup
        row[x] = 2
        row
      end
      self.class.new(new_cells)
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

    private

    INDEXES = [*0..3].flat_map { |y| [*0..3].map { |x| [y, x] } }.map(&:freeze).freeze

    def available?(y, x)
      rows[y][x] == 0
    end

    def perform_shift(rank_type:, increasing:)
      next_rows = rows.map { |row| row.dup }

      if increasing
        tos = 3.downto(0)
      else
        tos = 0.upto(3)
      end

      if rank_type == :column
        get = -> rank, index        { next_rows[index][rank]         }
        set = -> rank, index, value { next_rows[index][rank] = value }
      elsif rank_type == :row
        get = -> rank, index        { next_rows[rank][index]         }
        set = -> rank, index, value { next_rows[rank][index] = value }
      else
        raise "bug: #{rank_type.inspect} is not :column or :row"
      end

      (0..3).each do |rank|
        tos.each do |to|
          froms = increasing ? (to-1).downto(0) : (to+1).upto(3)
          froms.each do |from|
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


  class Bot
    attr_accessor :board
    def initialize(board)
      self.board = board
    end

    def move
      move_heuristics.max_by { |dir, score| score }.first
    end

    def move_heuristics
      [:up, :down, :left, :right]
        .map { |dir| [dir, heuristic(board.shift(dir))] }
    end

    # maybe the heuristic should be injectable?
    def heuristic(board)
      # Maybe ultimately consider these:
      #   fewer tiles is better
      #   tiles with higher numbers are worth more
      #   corners are better
      #   sequences of continually ascending / descending are better than flipping direction
      # But for now, just something super simple
      score = 0

      # larger tiles are worth more points
      for y in 0..3
        for x in 0..3
          score += (2**board[y, x])
        end
      end

      # tiles along the edge are worth more points
      # and prefer the larger tiles be along more edges
      (0..3).each do |edge|
        score += board[0, edge]
        score += board[3, edge]
        score += board[edge, 0]
        score += board[edge, 3]
      end
      score
    end
  end
end
