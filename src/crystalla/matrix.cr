require "./matrix/builders"
require "./matrix/stats"
require "./transformations/pca"

module Crystalla
  class Matrix
    include LapackHelper
    include BlasHelper

    getter number_of_rows
    getter number_of_cols
    getter values

    def initialize(@values : Array(Float64), @number_of_rows : Int32, @number_of_cols : Int32); end

    def self.[](*values : Array(Number)) : Matrix
      rows values.to_a
    end

    def [](row, col) : Float64
      values[row_col_to_index(row, col)]
    end

    def []=(row : Int32, col : Int32, value : Number)
      values[row_col_to_index(row, col)] = value.to_f64
    end

    def +(other : self) : Matrix
      zip_with(other) { |x, y| x + y }
    end

    def -(other : self) : Matrix
      zip_with(other) { |x, y| x - y }
    end

    def - : Matrix
      Matrix.new values.map(&.-), @number_of_rows, @number_of_cols
    end

    def * (other : self) : Matrix
      if number_of_cols != other.number_of_rows
        raise ArgumentError.new "number of rows/columns mismatch in matrix multiplication"
      end

      blas_multiply_matrix other
    end

    def prepend(row : Matrix) : Matrix
      add_rows(0, row)
    end

    def append(row : Matrix) : Matrix
      add_rows(@number_of_rows, row)
    end

    def row_vector? : Bool
      @number_of_rows == 1
    end

    def add_rows(index : Int32, rows : Matrix) : Matrix
      new_rows = [] of Array(Float64)
      insert_rows = ->{ rows.each_row { |row, row_index| new_rows.push row } }

      each_row do |row, row_index|
        insert_rows.call if index == row_index
        new_rows.push row
      end

      insert_rows.call if index >= @number_of_rows

      Matrix.rows new_rows
    end

    def shuffle_cols
      new_indices = Matrix.rand_perm(@number_of_cols)
      new_cols = Array.new(@number_of_cols, [] of Float64)

      each_col do |col, index|
        new_cols[new_indices.values[index].to_i] = col
      end

      Matrix.columns new_cols
    end

    def ==(other : Matrix) : Bool
      compare(other) { |index, value| value == other.values[index] }
    end

    def all_close(other : Matrix, absolute_tolerance = nil, relative_tolerance = nil) : Bool
      compare(other) { |index, value| value.close_to(other.values[index], absolute_tolerance, relative_tolerance) }
    end

    def compare(other : Matrix) : Bool
      return false unless self.dimensions == other.dimensions

      self.each do |index, value|
        return false unless yield(index, value)
      end

      true
    end

    def dimensions : Tuple(Int32, Int32)
      {number_of_rows, number_of_cols}
    end

    def inspect(io)
      to_s(io)
    end

    def clone : Matrix
      Matrix.new(@values.clone, @number_of_rows, @number_of_cols)
    end

    def invert! : Matrix
      unless square?
        raise ArgumentError.new "can't invert non-square matrix"
      end

      pivot_indices_array = Slice.new(number_of_rows, 0)

      lapack_lu!(pivot_indices_array)
      lapack_invert!(pivot_indices_array)

      self
    end

    def solve(b : self) : Matrix
      if self.number_of_rows != b.number_of_rows
        raise ArgumentError.new "right hand side must have the same number of rows as left hand side"
      end

      lu = self.clone
      x = b.clone
      lapack_solve(lu, x)

      x
    end

    protected def each
      (0...@values.size).each do |i|
        yield i, @values[i]
      end
    end

    def each_row
      (0...@number_of_rows).each do |i|
        row = [] of Float64
        (0...@number_of_cols).each do |j|
          row.push self[i, j]
        end
        yield row, i
      end
    end

    def each_col
      i = 0
      @values.each_slice(@number_of_rows) do |col|
        yield col.dup, i
        i += 1
      end
    end

    def each_by_row
      (0...@number_of_rows).each do |i|
        (0...@number_of_cols).each do |j|
          yield self[i, j], i, j
        end
      end
    end

    def each_by_col
      (0...@number_of_cols).each do |j|
        (0...@number_of_rows).each do |i|
          yield self[i, j], i, j
        end
      end
    end

    def zip_with(other : Matrix) : Matrix
      raise ArgumentError.new "number of rows mismatch in matrix operation" if number_of_rows != other.number_of_rows
      raise ArgumentError.new "number of columns mismatch in matrix operation" if number_of_cols != other.number_of_cols

      new_values = Array.new(@values.size, 0.0)
      self.each do |i, x|
        new_values[i] = yield x, other.values[i]
      end
      Matrix.new(new_values, number_of_rows, number_of_cols)
    end

    def square? : Bool
      number_of_rows == number_of_cols
    end

    def to_s(io)
      # We traverse all numbers to find out, per each column:
      # - The maximum number of digits to the left of the dot
      # - The maximum number of digits to the right of the dot
      infos = Array.new(number_of_cols, {0, 0})

      # While we traverse the values we collect the resulting strings,
      # together with left/right info
      strings = Array.new(values.size, {"", 0, 0})

      number_of_cols.times do |col|
        current = {0, 0}

        number_of_rows.times do |row|
          str = self[row, col].to_s
          dot_index = str.index('.')
          if dot_index
            left = dot_index
            right = str.bytesize - dot_index - 1
          else
            left = str.bytesize
            right = 0
          end

          strings[row_col_to_index(row, col)] = {str, left, right}

          current = {left, current[1]} if left > current[0]
          current = {current[0], right} if right > current[1]
          infos[col] = current
        end
      end

      # Now that we have all the info we need, we traverse the numbers again and
      # apply paddings as necessary.
      io << "Matrix["
      number_of_rows.times do |i|
        if i > 0
          io << ","
          io.puts
          #      Matrix[
          io << "       "
        end
        io << "[ "
        number_of_cols.times do |j|
          io << ", " if j > 0

          # Get string to format info
          str, left, right = strings[row_col_to_index(i, j)]

          # Get column info
          info_left, info_right = infos[j]

          # Apply padding to the left of the dot
          (info_left - left).times { io << " " }
          io << str

          # Apply padding to the right of the dot
          right_padding = info_right - right
          # Add one if the current number doesn't have a dot but the maximum does
          right_padding += 1 if right == 0 && info_right > 0
          right_padding.times { io << " " }
        end
        io << " ]"
      end
      io << "]"
    end

    def transpose : Matrix
      transposed = Matrix.new(Array.new(@values.size, 0.0), @number_of_cols, @number_of_rows)
      each_by_col do |val, i, j|
        transposed[j, i] = val
      end
      transposed
    end

    def svd : Tuple(Matrix, Array(Float64), Matrix)
      u = Matrix.zeros(@number_of_rows, @number_of_rows)
      vt = Matrix.zeros(@number_of_cols, @number_of_cols)
      s = Array.new([@number_of_rows, @number_of_cols].min, 0.0)
      lapack_svd(u, s, vt)
      return {u, s, vt}
    end

    def svd(count : Int32) : Tuple(Matrix, Array(Float64), Matrix)
      u = Matrix.zeros(@number_of_rows, count)
      vt = Matrix.zeros(count, @number_of_cols)
      s = Array.new([@number_of_rows, @number_of_cols].min, 0.0)

      {% if flag?(:dgesvdx) %}        
        lapack_partial_svd(u, s, vt, count)
      {% else %}
        u, s, vt = svd
        u = u[0..-1, 0...count]
        s = s[0...count]
        vt = vt[0...count, 0..-1]
      {% end %}

      return {u, s, vt}
    end

    def singular_values : Array(Float64)
      s = Array.new([@number_of_rows, @number_of_cols].min, 0.0)
      lapack_svd(nil, s, nil)
      s
    end

    def singular_values(count : Int32) : Array(Float64)
      {% if flag?(:dgesvdx) %}
        s = Array.new([@number_of_rows, @number_of_cols].min, 0.0)
        lapack_partial_svd(nil, s, nil, count)
        return s
      {% else %}
        singular_values[0...count]
      {% end %}
    end

    def [](rows : Range(Int32, Int32), cols : Range(Int32, Int32)) : Matrix
      if rows.end < 0
        rows = Range.new rows.begin, @number_of_rows + rows.end, rows.exclusive?
      end

      if cols.end < 0
        cols = Range.new cols.begin, @number_of_cols + cols.end, cols.exclusive?
      end

      validate_bounds(rows, cols)

      new_rows = [] of Array(Float64)
      rows.each do |i|
        row = [] of Float64
        cols.each do |j|
          row.push self[i, j]
        end
        new_rows.push row
      end
      Matrix.rows new_rows
    end

    # Returns the sum of the diagonal elements. Only useful for numeric matrices.
    def trace : Float64
      raise ArgumentError.new "Number of rows (#{number_of_rows}) does not match number of columns (#{number_of_cols})" unless square?
      (0...number_of_cols).sum(0.0) { |i| self[i, i] }
    end

    private def self.check_columns_have_same_number_of_rows(columns)
      return if columns.empty?

      number_of_rows = columns.first.size
      columns.each_with_index do |column, i|
        if column.size != number_of_rows
          raise ArgumentError.new "column ##{i + 1} must have #{number_of_rows} rows, not #{column.size}"
        end
      end
    end

    private def self.check_rows_have_same_number_of_rows(rows)
      return if rows.empty?

      number_of_cols = rows.first.size
      rows.each_with_index do |row, i|
        if row.size != number_of_cols
          raise ArgumentError.new "row ##{i + 1} must have #{number_of_cols} columns, not #{row.size}"
        end
      end
    end

    private def row_col_to_index(row, col)
      number_of_rows * col + row
    end

    def self.validate_dimensions(number_of_rows, number_of_cols)
      if number_of_rows < 0
        raise ArgumentError.new "negative number of rows"
      end

      if number_of_cols < 0
        raise ArgumentError.new "negative number of columns"
      end
    end

    private def validate_bounds(rows, cols)
      Matrix.validate_dimensions rows.begin, cols.begin

      if rows.end > @number_of_rows || (rows.end == @number_of_rows && !rows.excludes_end?)
        raise ArgumentError.new("requested rows are out of bounds")
      end

      if cols.end > @number_of_cols || (cols.end == @number_of_cols && !cols.excludes_end?)
        raise ArgumentError.new("requested cols are out of bounds")
      end
    end

    def to_unsafe
      values.to_unsafe
    end
  end
end
