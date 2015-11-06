module Crystalla
  class Matrix
    include LapackHelper
    include BlasHelper

    getter number_of_rows
    getter number_of_cols
    getter values

    def initialize(@values : Array(Float64), @number_of_rows : Int32, @number_of_cols : Int32); end

    def self.columns(columns : Array(Array(Float64))) : Matrix
      check_columns_have_same_number_of_rows columns
      Matrix.new columns.flatten, columns.first.size, columns.size
    end

    def self.columns(columns : Array(Array(Number))) : Matrix
      Matrix.columns columns.map(&.map(&.to_f))
    end

    def self.load(file : String) : Matrix
      rows = [] of Array(Float64)
      File.each_line(file) do |line|
        rows.push line.split.map(&.to_f)
      end
      Matrix.rows rows
    end

    def self.rows(rows : Array(Array(Number)))
      check_rows_have_same_number_of_rows rows
      Matrix.columns rows.transpose
    end

    def self.zeros(number_of_rows : Int32, number_of_cols : Int32) : Matrix
      self.constant_matrix(0, number_of_rows, number_of_cols)
    end

    def self.ones(number_of_rows : Int32, number_of_cols : Int32) : Matrix
      self.constant_matrix(1, number_of_rows, number_of_cols)
    end

    def self.constant_matrix(value : Number, number_of_rows : Int32, number_of_cols : Int32) : Matrix
      validate_dimensions(number_of_rows, number_of_cols)
      Matrix.new(Array.new(number_of_rows * number_of_cols, value.to_f), number_of_rows, number_of_cols)
    end

    def self.rand_perm(n : Int32) : Matrix
      raise ArgumentError.new("rand_perm given size must be greater than 0") if n <= 0
      Matrix.row_vector (0...n).to_a.shuffle
    end

    def self.row_vector(values : Array(Number)) : Matrix
      Matrix.rows [values]
    end

    def self.empty : Matrix
      Matrix.new(Array.new(0, 0.0), 0, 0)
    end

    def self.rand(number_of_rows : Int32, number_of_cols : Int32) : Matrix
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.next_float
      end

      Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.rand(number_of_rows : Int32, number_of_cols : Int32, range : Range(Int32, Int32)) : Matrix
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.rand(range).to_f
      end

      Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.diag(diagonal : Array(Number)) : Matrix
      diag(diagonal, diagonal.size, diagonal.size)
    end

    def self.diag(diagonal : Array(Number), number_of_rows : Int32, number_of_cols : Int32) : Matrix
      m = self.zeros(number_of_rows, number_of_cols)
      diagonal.each_with_index do |x, i|
        break if i >= number_of_rows || i >= number_of_cols
        m[i, i] = x
      end
      return m
    end

    def self.eye(number_of_rows_and_cols : Int32) : Matrix
      eye(number_of_rows_and_cols, number_of_rows_and_cols)
    end

    def self.eye(number_of_rows : Int32, number_of_cols : Int32) : Matrix
      validate_dimensions(number_of_rows, number_of_cols)

      values = Array.new(number_of_rows * number_of_cols, 0.0)
      [number_of_cols, number_of_rows].min.times do |i|
        values[number_of_rows * i + i] = 1.0
      end

      Matrix.new(values, number_of_rows, number_of_cols)
    end

    private def self.validate_dimensions(number_of_rows, number_of_cols)
      if number_of_rows < 0
        raise ArgumentError.new "negative number of rows"
      end

      if number_of_cols < 0
        raise ArgumentError.new "negative number of columns"
      end
    end

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
      raise ArgumentError.new "number of rows mismatch in matrix addition" if number_of_rows != other.number_of_rows
      raise ArgumentError.new "number of columns mismatch in matrix addition" if number_of_cols != other.number_of_cols

      added = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        added[i] = values[i] + other.values[i]
      end
      Matrix.new(added, number_of_rows, number_of_cols)
    end

    def - : Matrix
      Matrix.new values.map(&.-), @number_of_rows, @number_of_cols
    end

    def *(other : self) : Matrix
      if number_of_cols != other.number_of_rows
        raise ArgumentError.new "number of rows/columns mismatch in matrix multiplication"
      end

      blas_multiply other
    end

    def prepend(row) : Matrix
      add_row(0, row)
    end

    def append(row) : Matrix
      add_row(@number_of_rows, row)
    end

    def add_row(index, m : Matrix) : Matrix
      #TODO: maybe it just doesn't make sense to have
      #single row insertion methods. I should be able to
      #add any number of consecutive rows from an index in the
      #form of a matrix... it's much more handy!
      raise ArgumentError.new "matrix is not a row vector" unless m.row_vector?
      raise ArgumentError.new "matrix has a different number of columns" unless m.number_of_cols == number_of_cols

      add_row index, m.values.clone
    end

    def row_vector? : Bool
      @number_of_rows == 1
    end

    def add_row(index, row) : Matrix
      new_columns = [] of Array(Float64)

      i = 0
      @values.clone.each_slice(@number_of_rows) do |col|
        new_columns.push col.insert(index, row[i])
        i += 1
      end

      Matrix.columns new_columns
    end

    def ==(other : Matrix) : Bool
      compare(other) { |index, value| value == other.values[index] }
    end

    def all_close(other : Matrix, absolute_tolerance = nil , relative_tolerance = nil) : Bool
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

    def inspect(io) : String::Builder
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

    def square? : Bool
      number_of_rows == number_of_cols
    end

    def to_s(io) : String::Builder
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
      rows = [] of Array(Float64)
      @values.each_slice(number_of_rows) do |col|
        rows.push col
      end
      Matrix.rows rows
    end

    #TODO: maybe S should also be returned as a Matrix.
    # I guess it'll depend mostly on usage.
    def svd : Tuple(Matrix, Array(Float64), Matrix)
      u = Matrix.zeros(@number_of_rows, @number_of_rows)
      vt = Matrix.zeros(@number_of_cols, @number_of_cols)
      s = Array.new([@number_of_rows, @number_of_cols].min, 0.0)

      lapack_svd(u, s, vt)
      return {u, s, vt}
    end

    def singular_values : Array(Float64)
      s = Array.new([@number_of_rows, @number_of_cols].min, 0.0)
      lapack_svd(nil, s, nil)
      s
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

    def to_unsafe
      values.to_unsafe
    end
  end
end
