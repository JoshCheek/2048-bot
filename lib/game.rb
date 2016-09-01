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

    attr_accessor :rows

    def initialize(rows)
      self.rows = rows
    end

    def shift(direction)
      next_rows = rows.map { |row| row.dup }
      case direction
      when :up
        # for each col, start at the top and go down
        (0..3).each do |col|
          0.upto(3) do |y_to|
            (y_to+1).upto(3) do |y_from|
              to_value   = next_rows[y_to][col]
              from_value = next_rows[y_from][col]
              if to_value == 0 && from_value != to_value
                next_rows[y_to][col]   = from_value
                next_rows[y_from][col] = 0
                true
              elsif to_value == from_value
                next_rows[y_to][col]   = to_value + from_value
                next_rows[y_from][col] = 0
                true
              else
                false
              end
            end
          end
        end
      when :down
        # for each col, start at the bottom and go up
        raise 'fixme'
      when :left
        # for each row, start at the left and go right
        (0..3).each do |row|
          (0..3).each do |x_to|
            (x_to+1..3).each do |x_from|
              to_value   = next_rows[row][x_to]
              from_value = next_rows[row][x_from]
              if to_value == 0 && from_value != to_value
                next_rows[row][x_to]   = from_value
                next_rows[row][x_from] = 0
                true
              elsif to_value == from_value
                next_rows[row][x_to]   = to_value + from_value
                next_rows[row][x_from] = 0
                true
              else
                false
              end
            end
          end
        end
      when :right
        # for each row, start at the right and go left
        (0..3).each do |row|
          3.downto(0) do |x_to|
            (x_to-1).downto(0) do |x_from|
              to_value   = next_rows[row][x_to]
              from_value = next_rows[row][x_from]
              if to_value == 0 && from_value != to_value
                next_rows[row][x_to]   = from_value
                next_rows[row][x_from] = 0
                true
              elsif to_value == from_value
                next_rows[row][x_to]   = to_value + from_value
                next_rows[row][x_from] = 0
                true
              else
                false
              end
            end
          end
        end
      else raise ArgumentError, "Not a direction: #{direction.inspect}"
      end
      self.class.new next_rows
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

    private

    INDEXES = [*0..3].flat_map { |y| [*0..3].map { |x| [y, x] } }.map(&:freeze).freeze

    def available?(y, x)
      rows[y][x] == 0
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
      # fewer tiles is better
      # tiles with higher numbers are worth more
      # corners are better
      # sequences of continually ascending / descending are better than flipping direction

      sum = 0
      for y in 0..3
        # for now, just something super simple
        for x in 0..4
          sum += (2**board[y, x])
        end
      end
      sum
    end
  end
end
