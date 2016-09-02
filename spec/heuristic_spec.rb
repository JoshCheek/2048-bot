require 'game/board'
require 'game/heuristic'

RSpec.describe 'Heuristic' do
  def rank(rows)
    board = Game::Board[*rows]
    Game::Heuristic.rank(board)
  end

  it 'considers a joined tile better than its two components' do
    expect(rank [
      [0, 0, 0, 0],
      [0, 4, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]).to be > rank([
      [0, 0, 0, 0],
      [0, 2, 2, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ])
  end

  it 'considers a tile along the edge better than not along the edge' do
    expect(rank [
      [0, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]).to be > rank([
      [0, 0, 0, 0],
      [0, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ])
  end

  it 'considers a tile in the corner better than a tile not in the corner' do
    expect(rank [
      [2, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]).to be > rank([
      [0, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ])
  end
end
