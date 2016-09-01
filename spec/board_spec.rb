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

  describe '.random_start' do
    it 'places two tiles randomly on the board, those tiles have values of 2 or 4' do
      boards = 1000.times.map { Game::Board.random_start }.uniq
      expect(boards.length).to be < 1000 # sanity check, 16*15*2*2 < 1000
      expect(boards.length).to be > 1    # if its random, they're unlikely to all be the same
      all_tiles = boards.map { |b| b.tiles }.reduce(:|).sort
      expect(all_tiles).to eq [0, 2, 4]
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

    it 'shifts the tiles in the specified direction for as long as there are open spaces in that direction' do
      # left
      board = Game::Board[
        [2, 0, 0, 0],
        [0, 2, 0, 0],
        [0, 0, 2, 0],
        [4, 0, 0, 2],
      ]
      expect(board.shift :left).to eq Game::Board[
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
      expect(board.shift :right).to eq Game::Board[
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
      expect(board.shift :up).to eq Game::Board[
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
      expect(board.shift :down).to eq Game::Board[
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
      expect(board.shift :left).to eq Game::Board[
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
      expect(board.shift :down).to eq Game::Board[
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [2, 2, 4, 4],
        [4, 4, 4, 4],
      ]
    end
  end

  describe 'finished?' do
    it 'is false if there are open tiles' do
      expect(Game::Board[
        [0, 2, 4, 2],
        [8, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
      ]).to_not be_finished
    end
    it 'is false if it can be shifted in any direction' do
      # up/down
      expect(Game::Board[
        [8, 2, 4, 2],
        [8, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
      ]).to_not be_finished

      # left/right
      expect(Game::Board[
        [8, 8, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
      ]).to_not be_finished
    end

    it 'is true otherwise' do
      expect(Game::Board[
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
      ]).to be_finished
    end
  end

  describe '#[]' do
    let :board do
      Game::Board[
        [2, 8, 0, 0],
        [4, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]
    end

    it 'returns the value at the given y/x' do
      expect(board[0, 0]).to eq 2
      expect(board[1, 0]).to eq 4
      expect(board[0, 1]).to eq 8
    end

    it 'splodes if given an incorrect value' do
      expect { board[4, 0] }.to raise_error ArgumentError, /4/
      expect { board[0, 5] }.to raise_error ArgumentError, /5/
    end
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
