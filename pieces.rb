require 'singleton'
require 'colorize'
require_relative 'manifest'
class ImpossibleMove < StandardError
end
class Piece

  attr_accessor :board, :color, :pos

  def initialize(pos, color, board)
    @board = board
    @color = color
    @pos = pos
  end

  # def moves
  #   moves = move
  # end

  def move(to)
    board[*pos] = NullPiece.instance
    puts to.class
    puts to.inspect
    board[*to] = self
    self.pos = to
  end


  def present?
    true
  end

  def to_s
    " x "
  end

  def exception_unless_valid_move(pos)

  end
end

class SlidingPiece < Piece

  def possible_moves
    directions = move_dirs
    possible_moves = []

    directions.each do |dir|
      new_pos = (0..1).map { |idx| pos[idx] + dir[idx] }

      while board.inboard?(new_pos)
        if board[*new_pos] == NullPiece
          possible_moves << new_pos
        elsif board[*new_pos].color != self.color
          possible_moves << new_pos
          break
        else
          break
        end

        new_pos = (0..1).map { |idx| new_pos[idx] + dir[idx] }
      end
    end
    possible_moves
  end

  def exception_unless_valid_move(pos)

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
    [[1,0], [0,1], [0,-1] [-1,0]]
  end

  def to_s
    " " + "\u265C".encode('utf-8').colorize(color) + " "
  end

end

class Queen < SlidingPiece

  def move_dirs
    [[1,0], [0,1], [0,-1] [-1,0], [1,1], [1,-1], [-1,-1], [-1,1]]
  end

  def to_s
    " " + "\u265B".encode('utf-8').colorize(color) + " "
  end

end

class SteppingPiece < Piece

  def possible_moves
    directions = self.move_dirs
    possible_moves = []

    directions.each do |dir|
      new_pos = (0..1).map { |idx| pos[idx] + dir[idx] }

      if board.inboard?(new_pos)
        if board[*new_pos] == NullPiece
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

class NoPiece < StandardError

end

class NullPiece

 include Singleton

  def present?
    false
  end

  def exception_unless_valid_move(pos)
    raise NoPiece.new, "no piece in #{pos}}"
  end

  def move(pos)

  end

  def to_s
    "   "
  end
end
