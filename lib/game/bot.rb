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

    def heuristic(board)
      # Maybe ultimately consider these:
      #   fewer tiles is better
      #   tiles with higher numbers are worth more
      #   corners are better
      #   sequences of continually ascending / descending are better than flipping direction
      # But for now, just something super simple
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

      # sequences of continually ascending sequences are better
      # for each square,
      #   it is the root of a sequence up, down, left, and right of it
      #   the tile at that location is part of its sequence
      #   if it is greater than or equal to the current tile
      #   and not already part of the sequence

      sequences.map do |sequence|
        # not really sure how to rank them,
        # but longer sequences should be better,
        # and then after that, more sequences
        # (or maybe only count the longest sequence?)
        2 ** sequence.map { |_, _, val| val }.length
      end

      score
    end

    def sequences
      return @sequences if @sequences
      @sequences = []
      (0..3).each do |y|
        (0..3).each do |x|
          @sequences += sequences_from(y, x, [])
        end
      end
      @sequences
    end

    def sequences_from(y, x, sequence)
      _, _, prev = sequence.last
      crnt = board[y, x]
      return [] if crnt.zero?
      return [] if prev && crnt <= prev
      return [] if sequence.any? { |prev_y, prev_x, _|
        prev_y == y && prev_x == x
      }
      next_sequence = sequence + [[y, x, crnt]]
      sequences  = [next_sequence]
      sequences += sequences_from(y-1, x  , next_sequence) if 0 < y
      sequences += sequences_from(y+1, x  , next_sequence) if y < 3
      sequences += sequences_from(y  , x-1, next_sequence) if 0 < x
      sequences += sequences_from(y  , x+1, next_sequence) if x < 3
      sequences
    end
  end
end
