require 'game'

RSpec.describe 'Board' do
  describe '.from_array' do
    it 'splodes unless given a 4x4 array of integers that are powers of 2, except for 1'
    it 'returns a board with the cells of the array'
  end

  describe 'shift' do
    it 'splodes unless given a valid direction (:up, :down, :left, :right)'
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
        board = Game::Board.from_array [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]
        board.generate_tile.to_a
      end.uniq

      expect(boards.length).to be < 100 # sanity check

      boards.each do |board|
        tile_counts = board.tiles.group_by(&:itself)
                           .map { |tile, tiles| [tile, tiles.length] }
                           .to_h
        expect(tile_counts).to eq 0 => 15, 2 => 1
      end
    end
  end
end
