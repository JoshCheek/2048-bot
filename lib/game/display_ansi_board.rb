module Game
  class DisplayAnsiBoard
    def self.call(board)
      new(board).call
    end

    def initialize(board)
      self.board = board
    end

    def call
      rows           = board.to_a
      cols           = rows.transpose.map { |col| col.map &:to_s }
      max_width      = cols.flat_map { |col| col.map &:length }.max
      widths         = cols.map { max_width }
      margin_size    = 15
      horizontal     = BG + " "*widths.inject(margin_size, :+)+OFF+"\r\n"
      formats        = widths.map { |w| "%#{w}d" }
      formatted_rows = rows.map { |row|
        "#{BG}  " <<
          formats.zip(row).map do |format, tile|
            "#{colour(tile)} #{format % tile} "
          end.join("#{BG} ") <<
          "#{BG}  #{OFF}\r\n"
      }.join
      horizontal + formatted_rows + horizontal
    end

    private

    OFF = "\e[0m".freeze
    BG  = "\e[39;48;5;243m".freeze

    attr_accessor :board

    def rgb(r, g, b)
      "\e[1;38;5;255;48;5;#{16 + 36*r + 6*g + b}m"
    end

    def colour(tile)
      case tile
      when 0               then "\e[1;38;5;247;48;5;247m"
      when 2               then rgb(4,4,4)+"\e[1;38;5;237m"
      when 4               then rgb(4,4,3)+"\e[1;38;5;237m"
      when 8               then rgb(4,2,1)
      when 16              then rgb(5,2,1)
      when 32              then rgb(5,1,1)
      when 64              then rgb(5,1,0)
      when 128, 256        then rgb(5,3,1)
      when 512, 1024, 2048 then rgb(4,3,0)
      else                      "\e[1;38;5;251;48;5;236m"
      end
    end
  end
end
