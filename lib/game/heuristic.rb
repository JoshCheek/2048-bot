module Game
  class Heuristic
    # Some things that seem like they're probably valuable:
    #   fewer tiles is better
    #   tiles with higher numbers are worth more
    #   corners are better
    #   sequences of continually ascending / descending are better than flipping direction
    def self.rank(board)
      sequence = best_sequence(board)
      max_tile = sequence.max_by(&:last).last
      sequence.reduce(max_tile) do |score, (y, x, tile)|
        multiplier = 1
        multiplier *= 2 if y == 0
        multiplier *= 2 if x == 0
        multiplier *= 2 if y == 3
        multiplier *= 2 if x == 3
        score + multiplier * tile
      end
    end

    private

    # none of this is directly tested...
    # would probably be worth doing that, though

    def self.best_sequence(board)
      # sort first by highest tile,
      # second by longest sequence length
      sequences(board).max_by do |seq|
        [seq.max_by(&:last).last, seq.length]
      end
    end

    def self.sequences(board)
      sequences = []
      (0..3).each do |y|
        (0..3).each do |x|
          sequences += sequences_from(board, y, x, [])
        end
      end
      sequences
    end

    def self.sequences_from(board, y, x, sequence)
      _, _, prev = sequence.last
      crnt = board[y, x]
      return [] if crnt.zero?
      return [] if prev && crnt < prev
      return [] if sequence.any? { |prev_y, prev_x, _|
        prev_y == y && prev_x == x
      }
      next_sequence = sequence + [[y, x, crnt]]
      sequences  = [next_sequence]
      sequences += sequences_from(board, y-1, x  , next_sequence) if 0 < y
      sequences += sequences_from(board, y+1, x  , next_sequence) if y < 3
      sequences += sequences_from(board, y  , x-1, next_sequence) if 0 < x
      sequences += sequences_from(board, y  , x+1, next_sequence) if x < 3
      sequences
    end
  end
end
