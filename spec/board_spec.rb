require 'game/board'

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

    it 'returns a board with the tiles of the array' do
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

  describe '#won?' do
    it 'returns true once the board has seen a 2048 tile' do
      expect(Game::Board[
        [0, 0, 0,    0],
        [0, 0, 0,    0],
        [0, 0, 0, 2048],
        [0, 0, 0,    0],
      ]).to be_won
      expect(Game::Board[
        [0,    0, 0, 0],
        [0,    0, 0, 0],
        [0,    0, 0, 0],
        [0, 4096, 0, 0],
      ]).to be_won
      expect(Game::Board[
        [0, 1024, 0, 0],
        [0, 1024, 0, 0],
        [0,    0, 0, 0],
        [0,    0, 0, 0],
      ]).to_not be_won
    end
  end

  describe '#finished?' do
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
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 8, 4, 2],
        [2, 8, 2, 4],
      ]).to_not be_finished

      # left/right
      expect(Game::Board[
        [4, 2, 4, 2],
        [2, 4, 8, 8],
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

  describe '#add_random_tile' do
    it 'randomly inserts a 2 into an open spot 90% of the time, and a 4 10% of the time' do
      boards = 100.times.map do
        board = Game::Board[
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]
        board.add_random_tile
      end.uniq

      expect(boards.length).to be < 100 # sanity check, there are only 16 available positions
      expect(boards.length).to be > 1   # if random, they shouldn't all be the same

      saw_a_two = saw_a_four = false
      boards.each do |board|
        tile_counts = board.tiles.group_by(&:itself)
                           .map { |tile, tiles| [tile, tiles.length] }
                           .to_h
        expect(tile_counts[0]).to eq 15
        saw_a_two  ||= tile_counts[2]
        saw_a_four ||= tile_counts[4]
      end
      expect(saw_a_two).to be_truthy
      expect(saw_a_four).to be_truthy
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
          [ [4, 0, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
          ],
          [ [0, 4, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
            [8, 8, 8, 8],
          ],
        ]).to include(board.add_random_tile.to_a)
      end
    end

    it 'does not generate a tile when there are no empty locations' do
      board = Game::Board[
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
      ]
      expect(board.add_random_tile.to_a).to eq [
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
        [8, 8, 8, 8],
      ]
    end
  end

  describe '#to_s' do
    it 'returns a board that can be printed helpfully' do
      board1 = Game::Board[
        [0,  2,  4,   8],
        [0, 32, 64, 128],
        [0,  2,  4,   0],
        [0,  2,  4,   0],
      ]
      board2 = Game::Board[
        [   0,    2,     4,     8],
        [  16,   32,    64,   128],
        [ 256,  512,  1024,  2048],
        [4096, 8192, 16384, 32768],
      ]
      regex = Regexp.new(board1.to_a.flatten.join(".*"), Regexp::MULTILINE)
      # print "\e[H\e[2J"
      # puts board1
      # puts
      # puts board2
      # exit!
      expect(board1.to_s).to match regex
    end
  end
end
