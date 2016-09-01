require 'game'

RSpec.describe '2048 bot' do
  def bot_for(board)
    Game::Bot.new board
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
      [0, 0, 2, 4],
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

  it 'shifts in such a way that it combines tiles for as long as possible' do
    board = Game::Board.random_start
    100.times do
      bot   = bot_for(board)
      board = board.shift(bot.move).generate_tile
      raise "Bot lost! #{board}" if board.finished?
    end
    expect(board.max_tile).to be >= 128
  end
end
