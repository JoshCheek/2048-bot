require 'game/heuristic'
require 'game/shift_board'

# Thought:
# Try placing the piece in every spot rather than operating on a random spot as if it's surefire knowledge?
module Game
  class HeuristicBot
    attr_accessor :board, :depth, :cache

    def initialize(board, depth, cache={})
      self.board = board
      self.depth = depth
      self.cache = cache
    end

    def move
      direction, score = best_move(depth, board)
      direction
    end

    private

    def best_move(depth, board)
      shift = ShiftBoard.new(board)
      [:up, :down, :left, :right]
        .map { |direction|
          next_board = shift.call(direction)
          if board == next_board
            [direction, 0]
          else
            [direction, cached_heuristic(depth, next_board)]
          end
        }
        .max_by { |_direction, score| score }
    end

    def cached_heuristic(depth, board)
      cache[board] ||= calculate_heuristic(depth, board)
    end

    def calculate_heuristic(depth, board)
      if depth.zero? || board.finished?
        Heuristic.rank(board)
      else
        _, score1 = best_move(depth-1, board.generate_tile)
        _, score2 = best_move(depth-1, board.generate_tile)
        # run 2x in an attempt to mitigate lucky tile generation
        score1 < score2 ? score1 : score2
      end
    end
  end
end
