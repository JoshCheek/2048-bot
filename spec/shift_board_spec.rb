require 'game/shift_board'

RSpec.describe 'ShiftBoard' do
  def shift(board, direction)
    Game::ShiftBoard.call board, direction
  end

  it 'splodes unless given a valid direction (:up, :down, :left, :right)' do
    board = Game::Board[
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]
    shift board, :left
    shift board, :right
    shift board, :up
    shift board, :down
    expect { shift board, :inside_out }.to raise_error ArgumentError, /inside_out/
  end

  it 'shifts the tiles in the specified direction for as long as there are open spaces in that direction' do
    # left
    board = Game::Board[
      [2, 0, 0, 0],
      [0, 2, 0, 0],
      [0, 0, 2, 0],
      [4, 0, 0, 2],
    ]
    expect(shift board, :left).to eq Game::Board[
      [2, 0, 0, 0],
      [2, 0, 0, 0],
      [2, 0, 0, 0],
      [4, 2, 0, 0],
    ]

    # right
    board = Game::Board[
      [2, 0, 0, 0],
      [0, 2, 0, 0],
      [0, 0, 2, 0],
      [4, 0, 0, 2],
    ]
    expect(shift board, :right).to eq Game::Board[
      [0, 0, 0, 2],
      [0, 0, 0, 2],
      [0, 0, 0, 2],
      [0, 0, 4, 2],
    ]

    # up
    board = Game::Board[
      [2, 0, 0, 0],
      [0, 2, 0, 0],
      [0, 0, 2, 0],
      [4, 0, 0, 2],
    ]
    expect(shift board, :up).to eq Game::Board[
      [2, 2, 2, 2],
      [4, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]

    # down
    board = Game::Board[
      [2, 0, 0, 0],
      [0, 2, 0, 0],
      [0, 0, 2, 0],
      [4, 0, 0, 2],
    ]
    expect(shift board, :down).to eq Game::Board[
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [2, 0, 0, 0],
      [4, 2, 2, 2],
    ]
  end

  it 'consolidates equal value tiles that are shifted into each other' do
    board = Game::Board[
      [2, 2, 0, 0],
      [0, 2, 0, 2],
      [8, 0, 0, 8],
      [4, 0, 2, 4],
    ]
    expect(shift board, :left).to eq Game::Board[
      [ 4, 0, 0, 0],
      [ 4, 0, 0, 0],
      [16, 0, 0, 0],
      [ 4, 2, 4, 0],
    ]
  end

  it 'breaks merge ties by merging the ones farthest in the direction of movement (ie they pile up the way they would in physics' do
    board = Game::Board[
      [2, 2, 2, 0],
      [0, 2, 2, 4],
      [2, 0, 2, 2],
      [2, 2, 2, 2],
    ]
    expect(shift board, :down).to eq Game::Board[
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [2, 2, 4, 4],
      [4, 4, 4, 4],
    ]
  end
end
