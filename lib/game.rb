module Game
  class Board
    def self.from_array(cells)
      raise "wrong height!" if cells.length != 4 # TODO not tested
      raise "wrong width!"  if cells.map(&:length).any? { |w| w != 4 } # TODO not tested
      new cells
    end

    attr_accessor :cells

    def initialize(cells)
      self.cells = cells
    end

    def shift(direction)
      offset = case direction
               when :up    then [-1,  0]
               when :down  then [ 1,  0]
               when :left  then [ 0, -1]
               when :right then [ 0,  1]
               else raise "Wat: #{direction.inspect}"
               end
      raise 'IDK what should happen here, go make a board spec!'
      # cells.map.with_index do |row,
    end

    def finished?
      false # TODO should be smarter
    end

    def generate_tile
      y, x = INDEXES.select { |y, x| available? y, x }.sample
      return self unless y && x # an optimization
      new_cells = cells.map.with_index do |row, index|
        next row unless index == y
        row = row.dup
        row[x] = 2
        row
      end
      self.class.new(new_cells)
    end

    def to_a
      cells
    end

    # hash and eql? allow boards to be hash keys,
    # which allow them to be used in a a set,
    # which allow us to call .uniq on an array of them
    def hash
      cells.hash
    end
    def eql?(board)
      cells.eql?(board.cells)
    end

    def tiles
      cells.flatten
    end

    private

    INDEXES = [*0..3].flat_map { |y| [*0..3].map { |x| [y, x] } }.map(&:freeze).freeze

    def available?(y, x)
      cells[y][x] == 0
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
