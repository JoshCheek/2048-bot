require 'game/heuristic_bot'
require 'game/board'

RSpec.describe '2048 Bot' do
  def bot_for(board, depth=0)
    Game::HeuristicBot.new board, depth
  end

  it 'can shift left' do
    board = Game::Board[
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [4, 4, 2, 0],
    ]
    expect(bot_for(board).move).to eq :left
    expect(board.shift(:left).to_a).to eq [
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
    expect(board.shift(:down).to_a).to eq [
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
    expect(board.shift(:right).to_a).to eq [
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
    expect(board.shift(:up).to_a).to eq [
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
      board = board.shift(bot.move)
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
      board = board.shift(bot.move).generate_tile
    end
    puts board
    expect(board.max_tile).to eq 2048
  end
end
