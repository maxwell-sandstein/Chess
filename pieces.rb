require 'byebug'
require 'singleton'
require 'colorize'
require_relative 'manifest'
class ImpossibleMove < StandardError
end

Possible_move = Struct.new(:from, :to)

class Piece

  attr_accessor :board, :color, :pos, :moved

  def initialize(pos, color, board)
    @board = board
    @color = color
    @pos = pos
    @moved = false
  end

  def dup(dup_board)
    self.class.new(self.pos, self.color, dup_board)
  end

  def exception_unless_valid_move(pos)
    available_moves = possible_moves
    raise ImpossibleMove unless available_moves.include?(pos)
  end
  # def moves
  #   moves = move
  # end

  def move(to)
    board[*pos] = NullPiece.instance
    board[*to] = self
    self.pos = to
  end

  def possible_moves_with_piece
     moves = possible_moves
     moves.map do |pos|
       Possible_move.new(self.pos, pos)
     end
  end


  def present?
    true
  end

  def to_s
    " x "
  end
end

class SlidingPiece < Piece
  def possible_moves
    directions = move_dirs
    possible_moves = []

    directions.each do |dir| #pos[0,0] dir[1,1]
      # debugger
      new_pos = (0..1).map { |idx| pos[idx] + dir[idx] } #[1,1]

      while board.in_bounds?(new_pos)
        if board[*new_pos].class == NullPiece
          possible_moves << new_pos
        elsif board[*new_pos].color != self.color
          possible_moves << new_pos
          break
        else
          break
        end

        new_pos = (0..1).map { |idx| new_pos[idx] + dir[idx] } #[1,1] + [1,1]
      end
    end
    possible_moves
  end

end

class Bishop < SlidingPiece

  def move_dirs
    [[1,1], [1,-1], [-1,-1], [-1,1]]
  end

  def to_s
    " " + "\u265D".encode('utf-8').colorize(color) + " "
  end

end

class Rook < SlidingPiece

  def move_dirs
    [[1,0], [0,1], [0,-1], [-1,0]]
  end

  def to_s
    " " + "\u265C".encode('utf-8').colorize(color) + " "
  end

end

class Queen < SlidingPiece

  def move_dirs
    [[1,0], [0,1], [0,-1], [-1,0], [1,1], [1,-1], [-1,-1], [-1,1]]
  end

  def to_s
    " " + "\u265B".encode('utf-8').colorize(color) + " "
  end

end

class SteppingPiece < Piece

  def possible_moves
    directions = self.move_dirs
    possible_moves = []

    directions.each do |dir| #dir = [1,1] pos = [2,3]
      new_pos = (0..1).map { |idx| pos[idx] + dir[idx] } #[3,4]

      if board.in_bounds?(new_pos)
        if board[*new_pos].class == NullPiece
          possible_moves << new_pos
        elsif board[*new_pos].color != self.color
          possible_moves << new_pos
        end
      end
    end
    possible_moves
  end
end

class King < SteppingPiece

  def move_dirs
    [[1,1], [1,-1], [-1,1], [-1,-1], [0,1], [1,0], [-1,0], [0,-1]]
  end

  def to_s
    " " + "\u265A".encode('utf-8').colorize(color) + " "
  end


end

class Knight < SteppingPiece

  def move_dirs
    [[2,1], [-2,1], [2,-1], [-2,-1], [1,2], [-1,2], [1,-2], [-1,-2]]
  end

  def to_s
    " " + "\u265E".encode('utf-8').colorize(color) + " "
  end


end

class Pawn < SteppingPiece
  attr_accessor :move_dirs

  def move(to)
    @moved = true
    super(to)
  end

  def move_dirs
    color == :white ? white_move_dirs : black_move_dirs
  end

  def possible_moves
    directions = self.move_dirs
    possible_moves = []
    directions[:vertical].each do |vert|
      new_pos = (0..1).map { |idx| pos[idx] + vert[idx] } #[3,4]
      if board.in_bounds?(new_pos)
        if board[*new_pos].class == NullPiece
          possible_moves << new_pos
        end
      end
    end

    directions[:diagonal].each do |diag|
      new_pos = (0..1).map { |idx| pos[idx] + diag[idx] } #[3,4]
      if board.in_bounds?(new_pos)
        if board[*new_pos].class != NullPiece && board[*new_pos].color != self.color
          possible_moves << new_pos
        end
      end
    end
    possible_moves
  end

  def white_move_dirs
  {diagonal:[[-1, 1],[-1, -1]], vertical: [[-1, 0]] + white_jump}
  end

  def black_move_dirs
    {diagonal: [[1, 1],[1, -1]], vertical:[[1, 0]] + black_jump}
  end

  def white_jump
    moved == true ? [] : [[-2, 0]]
  end

  def black_jump
    moved == true ? [] : [[2, 0]]
  end

  def to_s
    " " + "\u265F".encode('utf-8').colorize(color) + " "
  end
end

class NoPiece < StandardError
  attr_accessor :message
  def initialize(message)
    self.message = message
  end
end

class NullPiece

 include Singleton

  def present?
    false
  end

  def exception_unless_valid_move(pos)
    raise NoPiece.new, "no piece in #{pos}"
  end

  def dup(board)
    NullPiece.instance
  end

  def move(pos)

  end

  def to_s
    "   "
  end
end
