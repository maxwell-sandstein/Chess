require_relative 'manifest'
class Board
  attr_accessor :grid, :selected, :color

  def in_bounds?(pos)
    pos.all? { |x| x.between?(0, 7) }
  end

  def initialize
    @grid = Array.new(8) {Array.new(8) {NullPiece.instance} }
    self.selected = nil
    populate
  end

  def [](row, col)
    grid[row][col]
  end

  def []=(row, col, piece)
    self.grid[row][col] = piece
  end

  def move(start, end_pos)
      begin
        self.selected = nil
        self[*start].exception_unless_valid_move(end_pos)
      rescue NoPiece => e  #these rescues will eventually need to be caught in play turn so it can retry
          puts e.message
      rescue ImpossibleMove => e
          puts e.message
      end

     move!(start, end_pos)
  end

  def move!(start, end_pos)
    self[*start].move(end_pos)
  end

  def rows
    @grid
  end

  def populate
    0.upto(7) do |col|
      self[1, col] = NullPiece.instance#Pawn.new(:white)
      self[6, col] = NullPiece.instance#Pawn.new("black")
    end

    place_majors(:white)
    place_majors(:black)
  end



  private

  def place_majors(color)
    row = color == :black ? 0 : 7

    self[row, 0] = Rook.new([row, 0], color, self)
    self[row, 1] = Knight.new([row, 1], color, self)
    self[row, 2] = Bishop.new([row, 2], color, self)
    self[row, 3] = Queen.new([row, 3], color, self)
    self[row, 4] = King.new([row, 4], color, self)
    self[row, 5] = Bishop.new([row, 5], color, self)
    self[row, 6] = Knight.new([row, 6], color, self)
    self[row, 7] = Rook.new([row, 7], color, self)
  end


end
