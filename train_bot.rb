$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'game/board'
require 'game/neural_network'
require 'game/shift_board'
require 'game/heuristic'
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

def translate_board(board)
  board.tiles.map { |tile| tile }
end

def play(brain:, turns:, board:)
  directions = {}
  turns.times do
    output    = brain.eval(translate_board board)
    direction = output.zip(DIRECTIONS).max_by(&:first).last
    directions[direction] = true
    board     = Game::ShiftBoard.call(board, direction)
  end
  p directions.keys
  board
end

training_count = 0
define_method :train_more do
  loop do
    training_count += 1
    # iterate from the top bots
    potentials = potentials
      .uniq
      .map { |trainer:, board:|
        board = play(brain: trainer.network, board: board, turns: 20)
        score = Game::Heuristic.rank(board)
        [{trainer: trainer, board: board}, score]
      }
      .sort_by { |_, score| -score }
      .take(100)
      .tap { |best| p training_count => best.map(&:last) }
      .map(&:first)

    # For each direction we can move in
    # train the bot that it should move there
    # for the current board.
    #
    # Then play each of the four forward,
    # and keep the one that did the best.
    # then loop
    potentials = potentials.flat_map do |trainer:, board:|
      shift = Game::ShiftBoard.new(board)
      DIRECTIONS.each_index.map do |index|
        expected = [0] * 4
        expected[index] = 1
        inputs       = translate_board(board)
        neurons      = trainer.network.feedforward(inputs)
        next_trainer = trainer.backpropagate(expected, neurons)

        outputs      = neurons.last
        raise outputs.inspect unless outputs.length == 4
        direction    = outputs.zip(DIRECTIONS).max_by(&:first).last
        next_board   = shift.call(direction)
        {trainer: next_trainer, board: next_board}
      end
    end
  end
end

begin
  train_more
rescue Interrupt
  binding.pry
end



# loop do
#   break if board.finished?
#   break if board.won?
#   bot   = Game::HeuristicBot.new(board, depth)
#   board = board.shift(bot.move)
#   show_frame board
#   board = board.generate_tile
#   show_frame board
# end
