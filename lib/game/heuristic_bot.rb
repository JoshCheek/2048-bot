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
      dir, score = best_move(depth, board)
      dir
    end

    def best_move(depth_to_consider, board)
      move_heuristics(depth_to_consider, board).max_by { |dir, score| score }
    end

    def move_heuristics(depth_to_consider, board)
      [:up, :down, :left, :right]
        .map { |dir| [dir, heuristic(depth_to_consider, board.shift(dir))] }
    end

    # Some things that seem like they're probably valuable:
    #   fewer tiles is better
    #   tiles with higher numbers are worth more
    #   corners are better
    #   sequences of continually ascending / descending are better than flipping direction
    def heuristic(depth_to_consider, board)
      if depth_to_consider.zero? || board.finished?
        rank_board(board)
      else
        dir, score = best_move(depth_to_consider-1, board.generate_tile)
        score
      end
    end

    def rank_board(board)
      score = 0

      # larger tiles are worth more points
      # implies fewer tiles is better
      for y in 0..3
        for x in 0..3
          score += (2**board[y, x])
        end
      end

      # tiles along the edge are worth more points
      # the larger the edge tile, the more points its worth
      # implies corners are better
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
