require_relative 'manifest'
class Board
  attr_accessor :grid, :selected, :color

  def in_bounds?(pos)
    pos.all? { |x| x.between?(0, 7) }
  end

  def self.fresh_board
    fresh_board = Board.new
    fresh_board.populate
    fresh_board
  end

  def dup
    dup = Board.new
    grid.each_with_index do |row, row_num|
      row.each_with_index do |square, col_num|
        dup[row_num, col_num] = square.dup(dup)
        # puts dup[row_num, col_num].class == self[row_num, col_num].class
        # puts dup[row_num, col_num] != self[row_num, col_num]
      end
    end
    # debugger
    dup
  end

  def initialize
    @grid = Array.new(8) {Array.new(8) {NullPiece.instance} }
    self.selected = nil
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
      # rescue ImpossibleMove => e
      #     puts e.message
      # retry
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
      self[1, col] = Pawn.new([1, col], :black, self)
      self[6, col] = Pawn.new([6, col], :white, self)
    end

    place_majors(:white)
    place_majors(:black)
  end

  def players_moves(players_color)
    pieces = players_pieces(players_color)
    moves = pieces.inject([]) do |prev_moves, piece|
      prev_moves + piece.possible_moves
    end

    moves
  end

  def players_moves_with_positions(players_color)
    pieces = players_pieces(players_color)
    moves = pieces.inject([]) do |prev_moves, piece|
      prev_moves + piece.possible_moves_with_piece
    end
    moves
  end


  def checkmate?(checked_color) #ASSUMES WE ARE ALREADY IN CHECK IF THIS IS CALLED
    # debugger
     moves = players_moves_with_positions(checked_color) #[Possible_move,Possible_move..] Possible_move => from = [0,1], to=> knight
     #debugger
     moves.none? do |move|
       moves_board = self.dup
       stop_check?(moves_board, move, checked_color)
     end
  end

  def stop_check?(dup_board, move_struct, checked_color)
    to = move_struct.to
    from = move_struct.from
    dup_board.move!(from, to)
    !dup_board.in_check?(checked_color)
  end

  def opposite_color(color)
    color == :white ? :black : :white
  end

  def in_check?(color)
    opponents_color = opposite_color(color)
    king = find_king(color)
    threats = players_moves(opponents_color)
    threats.include?(king.pos)
  end

  def find_king(color)
    arr = grid.flatten.select do |piece|
      piece.class == King &&
      color == piece.color
    end
    arr[0]
  end

  def players_pieces(color)
    grid.flatten.select do |piece|
      piece.class != NullPiece && piece.color == color
    end
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
