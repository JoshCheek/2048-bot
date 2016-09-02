$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'game'

def show_frame(board)
  print "\e[H\e[2J"
  puts board
  # sleep 0.01
end

depth = 5
board = Game::Board.random_start

loop do
  break if board.finished?
  break if board.won?
  bot   = Game::Bot.new(board, depth)
  board = board.shift(bot.move)
  show_frame board
  board = board.generate_tile
  show_frame board
end
