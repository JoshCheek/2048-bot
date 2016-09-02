module Game
  class Heuristic
    # Some things that seem like they're probably valuable:
    #   fewer tiles is better
    #   tiles with higher numbers are worth more
    #   corners are better
    #   sequences of continually ascending / descending are better than flipping direction
    def self.rank(board)
      score = 0

      # larger tiles are worth more points
      # implies fewer tiles is better
      board.each_row do |row|
        row.each { |tile| score += (2**tile) }
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
