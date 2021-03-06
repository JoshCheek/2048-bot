require 'game/board'
require 'game/shift_board'
require 'game/heuristic_bot'

RSpec.describe '2048 Bot' do
  def bot_for(board, depth: 0, cache: {})
    Game::HeuristicBot.new board, depth, cache
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

  it 'does not take moves that do nothing' do
    board = Game::Board[
      [16, 16, 256, 512],
      [ 8, 64,  16,   4],
      [ 4, 16,   4,  32],
      [ 2,  2,   2,   2],
    ]
    move = bot_for(board).move
    expect([:left, :right]).to include move
  end

  it 'shifts in such a way that it combines tiles with some rudimentary intelligence' do
    board = Game::Board.random_start
    cache = {}
    200.times do |i|
      bot   = bot_for(board, depth: 1, cache: cache)
      board = shift(board, bot.move)
      board = board.add_random_tile
      raise "Bot lost! #{board}" if board.finished?
    end
    expect(board.max_tile).to be >= 128
  end

  xit 'can beat the game' do
    board = Game::Board.random_start
    cache = {}
    loop do
      break if board.finished?
      break if board.won?
      bot   = bot_for(board, depth: 2, cache: cache)
      board = board.shift(board, bot.move).add_random_tile
    end
    puts board
    expect(board.max_tile).to eq 2048
  end
end
