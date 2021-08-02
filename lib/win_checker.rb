# frozen_string_literal: true

# Provides a check to determine if a game is finished or not
class WinChecker
  attr_reader :grid
  attr_accessor :indexes, :drawn

  def initialize(args)
    @grid = args[:grid]
    @indexes = []
    @drawn = false
  end

  def finished?(row, col)
    return true if consecutive_elements_in_plain?(col, row) || consecutive_elements_in_diagonals?(col, row)

    @drawn = true if @grid.map { |g| g.compact.length }.uniq.eql?([6])
    !@indexes.empty? || drawn
  end

  def consecutive_elements_in_plain?(col, row)
    if cons_elements(@grid[col])&.any?
      @indexes = plain_indexes(row_f: @grid[col], row_idx: nil, col_idx: col)
    elsif cons_elements(@grid.transpose[row])&.any?
      @indexes = plain_indexes(row_f: @grid.transpose[row], row_idx: row, col_idx: nil)
    end

    !@indexes.empty?
  end

  def consecutive_elements_in_diagonals?(col, row)
    if cons_elements(diagonals(row, col).first.map(&:first))&.any?
      right_diagonal_indexes(row, col)
    elsif cons_elements(diagonals(row, col).last.map(&:first))&.any?
      left_diagonal_indexes(row, col)
    end

    !@indexes.empty?
  end

  def right_diagonal_indexes(row, col)
    @indexes = diagonals(row, col).first.map do |a|
      a.last if a.first == cons_elements(diagonals(row, col).first.map(&:first)).first
    end .compact
  end

  def left_diagonal_indexes(row, col)
    @indexes = diagonals(row, col).last.map do |a|
      a.last if a.first == cons_elements(diagonals(row, col).last.map(&:first)).first
    end .compact
  end

  def cons_elements(row_f)
    row_f.each_cons(4).find { |a, b, c, d| a == b && b == c && c == d }
  end

  def diagonals(row, col)
    get_diagonals(@grid, row, col)
  end

  def get_diagonals(arr, row_idx, col_idx)
    ncols = arr.first.size
    sum_idx = row_idx + col_idx
    diff_idx = row_idx - col_idx
    array = Array.new(arr.size * arr.first.size) { |i| i.divmod(ncols) }
    diagonal_arrays(array, sum_idx, diff_idx, row_idx, arr)
  end

  def diagonal_arrays(array, sum_idx, diff_idx, row_idx, arr)
    [array.select { |r, c| r - c == diff_idx }, array.select { |r, c| r + c == sum_idx }]
      .map do |b|
      b.sort_by { |r, _| [r > row_idx ? 0 : 1, r] }
       .map { |r, c| [arr[r][c], [r, c]] }
    end
  end

  def plain_indexes(row_f:, row_idx: nil, col_idx: nil)
    row_f.each_cons(4).each_with_index.map do |a, i|
      if a[0] == a[1] && a[1] == a[2] && a[2] == a[3]
        (i..i + 3).to_a.map { |c| col_idx ? [col_idx, c] : [c, row_idx] }
      end
    end.compact.last
  end
end
