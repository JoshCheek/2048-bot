module Game
  class ShiftBoard
    def self.call(board, direction)
      new(board).call(direction)
    end

    def initialize(board)
      self.board = board
    end

    def call(direction)
      case direction
      when :right then perform_shift rank_type: :row,    increasing: true
      when :left  then perform_shift rank_type: :row,    increasing: false
      when :down  then perform_shift rank_type: :column, increasing: true
      when :up    then perform_shift rank_type: :column, increasing: false
      else raise ArgumentError, "Not a direction: #{direction.inspect}"
      end
    end

    private

    attr_accessor :board

    def perform_shift(rank_type:, increasing:)
      next_rows = board.rows.map { |row| row.dup }

      if rank_type == :column
        get = -> rank, index        { next_rows[index][rank]         }
        set = -> rank, index, value { next_rows[index][rank] = value }
      elsif rank_type == :row
        get = -> rank, index        { next_rows[rank][index]         }
        set = -> rank, index, value { next_rows[rank][index] = value }
      else
        raise "bug: #{rank_type.inspect} is not :column or :row"
      end

      if increasing
        tos   = 3.downto(0)
        froms = -> to { (to-1).downto(0) }
      else
        tos   = 0.upto(3)
        froms = -> to { (to+1).upto(3) }
      end

      (0..3).each do |rank|
        tos.each do |to|
          froms[to].each do |from|
            to_value   = get[rank, to]
            from_value = get[rank, from]
            if from_value == 0
              # nothing to move
            elsif to_value == 0
              # anything can move to here, and values after it can combine with it
              set[rank, to,   from_value]
              set[rank, from, 0]
            elsif to_value == from_value
              # combine and move onto the next one (only one combination allowed per tile)
              set[rank, to,   to_value + from_value]
              set[rank, from, 0]
              break
            else
              # can't combine and squares after the tile can't move through it
              break
            end
          end
        end
      end

      board.class.new next_rows
    end
  end
end
