require 'game/board'
require 'game/shift_board'
require 'game/heuristic_bot'

RSpec.describe '2048 Bot' do
  def bot_for(board, depth=0)
    Game::HeuristicBot.new board, depth
  end

  def shift(board, direction)
    Game::ShiftBoard.call board, direction
  end

  it 'can shift left' do
    board = Game::Board[
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [4, 4, 2, 0],
    ]
    expect(bot_for(board).move).to eq :left
    expect(shift(board, :left).to_a).to eq [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [8, 2, 0, 0],
    ]
  end

  it 'can shift down' do
    board = Game::Board[
      [0, 0, 0, 0],
      [2, 0, 0, 0],
      [4, 0, 0, 0],
      [4, 0, 0, 0],
    ]
    expect(bot_for(board).move).to eq :down
    expect(shift(board, :down).to_a).to eq [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [2, 0, 0, 0],
      [8, 0, 0, 0],
    ]
  end

  it 'can shift right' do
    board = Game::Board[
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 2, 4, 4],
    ]
    expect(bot_for(board).move).to eq :right
    expect(shift(board, :right).to_a).to eq [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 2, 8],
    ]
  end

  it 'can shift up' do
    board = Game::Board[
      [0, 0, 0, 4],
      [0, 0, 0, 4],
      [0, 0, 0, 2],
      [0, 0, 0, 0],
    ]
    expect(bot_for(board).move).to eq :up
    expect(shift(board, :up).to_a).to eq [
      [0, 0, 0, 8],
      [0, 0, 0, 2],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]
  end

  it 'shifts in such a way that it combines tiles with some rudimentary intelligence', t:true do
    board = Game::Board.random_start
    200.times do |i|
      bot   = bot_for(board, 1)
      board = shift(board, bot.move)
      board = board.generate_tile
      raise "Bot lost! #{board}" if board.finished?
    end
    expect(board.max_tile).to be >= 128
  end

  xit 'can beat the game' do
    board = Game::Board.random_start
    loop do
      break if board.finished?
      break if board.won?
      bot   = bot_for(board)
      board = board.shift(board, bot.move).generate_tile
    end
    puts board
    expect(board.max_tile).to eq 2048
  end
end
