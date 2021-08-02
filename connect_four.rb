# frozen_string_literal: true

require 'colorize'

require_relative 'lib/win_checker'

# Connect four game
class ConnectFour
  SIDEBAR = (1..6).to_a
  BORDER = ('A'..'G').to_a
  HEIGHT = 6
  WIDTH = 7

  private_constant :SIDEBAR, :BORDER, :HEIGHT, :WIDTH

  attr_reader :players

  attr_accessor :col, :grid, :index, :row
  def initialize
    @grid = Array.new(WIDTH) { Array.new(HEIGHT) }
    @index = 1
    @col = @row = nil
    @players = %w[R B]
  end

  def play
    move
  end

  def move
    display_grid
    puts "#{current_player}'s turn. Place your move".green
    validate_input
    @row = @grid[col].index(nil)
    @grid[col][row] = players[index]
    game_finished?
  end

  def game_finished?
    if win_checker.finished?(row, col)
      if win_checker.drawn
        display_grid
        puts 'Game is drawn'.green
      else
        display_with_colour(win_checker.indexes)
      end
    else
      move
    end
  end

  def validate_input
    @col = gets.chomp.to_i - 1
    return unless !SIDEBAR.include?(@col + 1) || @grid[@col].compact.length >= HEIGHT

    puts 'Invalid input. Please enter again'.red
    validate_input
  end

  def display_grid
    puts `clear`
    puts board
    puts '----------------'
    puts '  ' + BORDER.join('|')
  end

  def board
    HEIGHT.downto(1).map do |i|
      SIDEBAR[i - 1].to_s + '|' + @grid.transpose[i - 1].map { |x| x.nil? ? ' ' : x }
                                       .join('|') + '|'
    end
  end

  def display_with_colour(array)
    array.each { |i, j| @grid[i][j] = @grid[i][j]&.yellow }
    display_grid
    puts winner_announcement(array)
  end

  def winner_announcement(array)
    "#{players[index]} has won by having four tokens in rows #{
      sentence(array.map do |_a, b|
        (b + 1).to_s
      end.uniq)} and in columns #{sentence(array.map { |a, _b| BORDER[a] }.uniq)}".green
  end

  def current_player
    @index = index == 1 ? 0 : 1
    players[index]
  end

  def sentence(array = nil)
    return array.first if array.length == 1

    array[0..-2].join(', ') + ' and ' + array[-1]
  end

  def win_checker
    @win_checker ||= WinChecker.new(grid: grid)
  end
end

ConnectFour.new.play
