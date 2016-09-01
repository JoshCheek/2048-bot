require 'game'

RSpec.describe 'Board' do
  describe '.[]' do
    it 'splodes unless given a 4x4 array of integers that are 0, or 2**n for n > 0' do
      # wrong number of rows
      expect { Game::Board[
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ] }.to raise_error ArgumentError, /rows/

      # wrong number of cols
      expect { Game::Board[
        [0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ] }.to raise_error ArgumentError, /col/

      # /1/, violates that n is an integer
      expect { Game::Board[
        [/1/, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ] }.to raise_error ArgumentError, /\/1\//

      # 2**0 = 1, violates that n > 0
      expect { Game::Board[
        [1, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ] }.to raise_error ArgumentError, /1/

      # 111 is not a power of 2
      expect { Game::Board[
        [111, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ] }.to raise_error ArgumentError, /111/
    end

    it 'returns a board with the cells of the array' do
      expect { Game::Board[
        [ 0,  2,  4,   8],
        [16, 32, 64, 128],
        [ 0,  0,  0,   0],
        [ 0,  0,  0,   0],
      ] }.to_not raise_error
    end
  end

  describe 'shift' do
    it 'splodes unless given a valid direction (:up, :down, :left, :right)' do
      board = Game::Board[
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]
      board.shift :left
      board.shift :right
      board.shift :up
      board.shift :down
      expect { board.shift :inside_out }.to raise_error ArgumentError, /inside_out/
    end

    it 'shifts the tiles in the specified direction for as long as there are open spaces in that direction'
    it 'consolidates equal value tiles that are shifted into each other'
    it 'breaks merge ties by merging the ones farthest in the direction of movement (ie they pile up the way they would in physics'
  end

  describe 'finished?' do
    it 'is false if there are open tiles'
    it 'is false if it can be shifted in any direction'
    it 'is true otherwise'
  end

  describe 'generate_tile' do
    it 'randomly inserts a 2 into an open spot (really, I should look at their code to figure out how they generate tiles, sometimes they do 4s, and they seem to weighted based on the board' do
      boards = 100.times.map do
        board = Game::Board[
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]
        board.generate_tile
      end.uniq

      expect(boards.length).to be < 100 # sanity check, there are only 16 available positions
      expect(boards.length).to be > 1   # if random, they shouldn't all be the same

      boards.each do |board|
        expect(board.tiles.group_by(&:itself)
                    .map { |tile, tiles| [tile, tiles.length] }
                    .to_h).to eq 0 => 15, 2 => 1
      end
    end

    it 'only generates on empty locations' do
      100.times do
        board = Game::Board[
          [0, 0, 8, 8],
          [8, 8, 8, 8],
          [8, 8, 8, 8],
          [8, 8, 8, 8],
        ]
        expect([
          [ [2, 0, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
          ],
          [ [0, 2, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
          ],
        ]).to include(board.generate_tile.to_a)
      end
    end

    it 'does not generate a tile when there are no empty locations' do
      board = Game::Board[
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
      ]
      expect(board.generate_tile.to_a).to eq [
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
      ]
    end
  end
end
