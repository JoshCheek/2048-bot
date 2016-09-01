module Game
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
