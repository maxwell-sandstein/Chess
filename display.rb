# require 'colorize'
# require_relative "cursorable"
require 'byebug'
require_relative 'manifest'
# class Display
#
#   include Cursorable
#   def initialize(board = nil)
#       @cursor = [7, 0]
#       @selected = false
#       @board = board
#   end
#
#   def render
#
#     row_num = 8
#     (0..7).each do |row|
#       print row_num
#       row_num -= 1
#       (0..7).each do |col|
#         case
#         when [row , col] == @cursor
#           print "  ".on_light_yellow #replace the 3 of these with board[row, col].
#         when (row + col).odd?
#           print "  ".on_light_black
#         when (row + col).even?
#           print "  ".on_light_white
#         end
#       end
#       puts
#     end
#     print " "
#     ("a".."h").each do |col|
#       print " #{col}"
#     end
#   end
#
#
# end

require "colorize"
require_relative "cursorable"
require_relative "board"

class Display
  include Cursorable
  attr_accessor :board
  def initialize(board = Board.new)
    @board = board
    @cursor_pos = [7, 0]
  end

  def build_grid
    # debugger
    @board.rows.map.with_index do |row, i|
      build_row(row, i)
    end
  end

  def facilitate_play_turn
    from = board.selected #board.selected is nil after move is called
    until from do
      render
      from = get_input
    end
    board.selected = from

    to = nil
    until to do
      render
      to = get_input
    end

    board.move(from, to)
    render #please comment out
    sleep(5)
  end

  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = colors_for(i, j)
      piece.to_s.colorize(color_options)
    end
  end

  def colors_for(i, j)  #needs to be changed to handle selected
    if [i, j] == @cursor_pos
      bg = :light_yellow
    elsif [i,j] == board.selected
      bg = :red
    elsif (i + j).odd?
      bg = :blue
    else
      bg = :green
    end
    { background: bg, color: :white }
  end

  def testing
    loop do


      get_input
      render


    end
  end

  def render
    system("clear")
    puts "Fill the grid!"
    puts "Arrow keys, WASD, or vim to move, space or enter to confirm."
    file_num = 8
    build_grid.each do |row|  #after build_grid a given space in the grid is its graphical representation
      row.unshift(file_num)
      puts row.join
      file_num -= 1
    end
    column_display = "  " + ("A".."H").to_a.join("  ")
    puts column_display
  end
end

# a = Display.new
# a.testing
displayboardtest= Display.new
displayboardtest.facilitate_play_turn
