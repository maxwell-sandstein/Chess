require_relative 'manifest'
class Game
  attr_accessor :board, :display, :turn

  def initialize
    @board = Board.fresh_board
    @display = Display.new(board)
  end

  def play
    @turn = :white
    until over?
      play_turn
    end
  end

  def play_turn
    begin
     display.facilitate_play_turn
    rescue NoPiece => e
        puts e.message
        retry
    rescue ImpossibleMove => e
        puts e.message
        retry
    end

    change_turn
  end

  def change_turn
    self.turn = turn == :white ? :black : :white
  end

  def over?

  end
end
