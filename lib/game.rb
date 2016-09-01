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
      raise 'fixme (shift)'
    end

    def finished?
      false # TODO should be smarter
    end

    def generate_tile
      raise 'fidme (random insertion of 2 or 4... there may be rules about when to do which, idk)'
    end

    def to_a
      cells
    end
  end


  class Bot
    attr_accessor :board
    def initialize(board)
      self.board = board
    end

    def move
      # for each possible move
      # make the move
      # calculate a heuristic of how good the board is
      # select the move with the best heuristic score
      # eventually, go several moves deep for this heuristic
      raise 'fixme (move)'
    end
  end
end
