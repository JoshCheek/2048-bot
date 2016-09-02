$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'game/board'
require 'game/neural_network'
require 'game/heuristic_bot'
require 'pry'
def show_frame(board)
  print "\e[H\e[2J"
  puts board
  # sleep 0.01
end

DIRECTIONS = [:up, :down, :left, :right]
potentials = [
  { trainer: NeuralNetwork::Trainer.init(
      layer_sizes:   [16, 8, 8, 4],
      learning_rate: 0.25,
      momentum:      0.1,
    ),
    board: Game::Board.random_start,
  },
]

MAX_TILE = 32768.0
def translate_board(board)
  board.tiles.map { |tile| tile / MAX_TILE }
end

def rank(brain:, turns:)
  board = Game::Board.random_start
  turns.times do
    output    = brain.eval(translate_board board)
    direction = output.zip(DIRECTIONS).max_by(&:first).last
    board     = board.shift(direction)
  end
  Game::HeuristicBot.new(board, 0).rank_board(board)
end

at_exit {
  binding.pry
}

2001.times do |i|
  # iterate from the top 100 bots
  potentials = potentials
    .map { |potential|
      score = rank(brain: potential[:trainer].network, turns: 100)
      [potential, score]
    }
    .sort_by { |_, score| -score }
    .take(100)
    .tap { |best| p i => best.map(&:last) }
    .map(&:first)

  # For each direction we can move in
  # train the bot that it should move there
  # for the current board.
  #
  # Then play each of the four forward,
  # and keep the one that did the best.
  # then loop
  potentials = potentials.flat_map do |trainer:, board:|
    DIRECTIONS.each_index.map do |index|
      expected = [0] * 4
      expected[index] = 1
      inputs       = translate_board(board)
      neurons      = trainer.network.feedforward(inputs)
      next_trainer = trainer.backpropagate(expected, neurons)

      outputs      = neurons.last
      raise outputs.inspect unless outputs.length == 4
      direction    = outputs.zip(DIRECTIONS).max_by(&:first).last
      next_board   = board.shift(direction)
      {trainer: next_trainer, board: next_board}
    end
  end
end

require "pry"
binding.pry

# loop do
#   break if board.finished?
#   break if board.won?
#   bot   = Game::HeuristicBot.new(board, depth)
#   board = board.shift(bot.move)
#   show_frame board
#   board = board.generate_tile
#   show_frame board
# end
