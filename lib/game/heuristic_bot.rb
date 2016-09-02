require 'game/heuristic'
require 'game/shift_board'

# Thought:
# Try placing the piece in every spot rather than operating on a random spot as if it's surefire knowledge?
module Game
  class HeuristicBot
    attr_accessor :board, :depth

    def initialize(board, depth)
      self.board = board
      self.depth = depth
    end

    def move
      direction, score = best_move(depth, board)
      direction
    end

    private

    def best_move(depth_to_consider, board)
      shift = ShiftBoard.new(board)
      [:up, :down, :left, :right]
        .map { |direction|
          [ direction,
            heuristic(depth_to_consider, shift.call(direction))
          ]
        }
        .max_by { |_direction, score| score }
    end

    def heuristic(depth_to_consider, board)
      if depth_to_consider.zero? || board.finished?
        Heuristic.rank(board)
      else
        _direction, score = best_move(
          depth_to_consider-1,
          board.generate_tile
        )
        score
      end
    end
  end
end
