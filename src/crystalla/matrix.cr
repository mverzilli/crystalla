module Crystalla
  class Matrix
    getter number_of_rows
    getter number_of_cols
    getter values

    def initialize(@values : Array(Float64), @number_of_rows : Int32, @number_of_cols : Int32); end

    def self.columns(columns : Array(Array(Float64)))
      check_columns_have_same_number_of_rows columns
      Matrix.new columns.flatten, columns.first.size, columns.size
    end

    def self.columns(columns : Array(Array(Number)))
      Matrix.columns columns.map(&.map(&.to_f))
    end

    def self.load(file)
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

    def self.zeros(number_of_rows, number_of_cols)
      validate_dimensions(number_of_rows, number_of_cols)

      Matrix.new(Array.new(number_of_rows * number_of_cols, 0.0), number_of_rows, number_of_cols)
    end

    def self.rand(number_of_rows, number_of_cols)
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.next_float
      end

      Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.rand(number_of_rows, number_of_cols, range)
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.rand(range).to_f
      end

      Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.eye(number_of_rows_and_cols)
      eye(number_of_rows_and_cols, number_of_rows_and_cols)
    end

    def self.eye(number_of_rows, number_of_cols)
      validate_dimensions(number_of_rows, number_of_cols)

      values = Array.new(number_of_rows * number_of_cols, 0.0)
      [number_of_cols, number_of_rows].min.times do |i|
        values[number_of_rows * i + i] = 1.0
      end

      Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.validate_dimensions(number_of_rows, number_of_cols)
      if number_of_rows < 0
        raise ArgumentError.new "negative number of rows"
      end

      if number_of_cols < 0
        raise ArgumentError.new "negative number of columns"
      end
    end

    def [](i, j)
      values[number_of_rows * j + i]
    end

    def []=(i, j, x)
      values[number_of_rows * j + i] = x
    end

    def *(other : self)
      if number_of_cols != other.number_of_rows
        raise ArgumentError.new "number of rows/columns mismatch in matrix multiplication"
      end

      c = Matrix.zeros(number_of_rows, other.number_of_cols)
      LibBlas.dgemm(
        LibBlas::Order::ColMajor,                                 # order
        LibBlas::Transpose::NoTrans, LibBlas::Transpose::NoTrans, # transa, transb
        number_of_rows, other.number_of_cols, number_of_cols,     # m, n, k
        1.0, self, ld,                                            # alpha, a, lda
        other, other.ld,                                          # b, ldb
        1.0, c, c.ld                                              # beta, c, ldc
      )
      c
    end

    def prepend(row)
      add_row(0, row)
    end

    def append(row)
      add_row(@number_of_rows, row)
    end

    def add_row(index, row)
      new_columns = [] of Array(Float64)

      i = 0
      @values.each_slice(@number_of_rows) do |col|
        new_columns.push col.insert(index, row[i])
        i += 1
      end

      Matrix.columns new_columns
    end

    def ==(other : Matrix)
      compare(other) { |index, value| value == other.values[index] }
    end

    def all_close(other)
      compare(other) { |index, value| value.close_to(other.values[index]) }
    end

    def compare(other)
      return false unless self.dimensions == other.dimensions

      self.each do |index, value|
        return false unless yield(index, value)
      end

      true
    end

    def dimensions
      {number_of_rows, number_of_cols}
    end

    def inspect(io)
      to_s(io)
    end

    def clone
      Matrix.new(@values.clone, @number_of_rows, @number_of_cols)
    end

    def invert!
      unless square?
        raise ArgumentError.new "can't invert non-square matrix"
      end

      pivot_indices_array = Slice.new(number_of_rows, 0)
      lapack_feedback = lapack_lu(pivot_indices_array)
      raise "LU failed: code #{lapack_feedback}" if lapack_feedback != 0
      lapack_feedback = lapack_invert(pivot_indices_array)
      raise "sgetri_ returned an error!" if lapack_feedback != 0
      self
    end

    def solve(b : self)
      raise ArgumentError.new "right hand side must have the same number of rows as left hand side"\
        if self.number_of_rows != b.number_of_rows
      lu = self.clone
      x = b.clone
      lapack_feedback = lapack_solve(lu, x)
      raise "Solve failed: code #{lapack_feedback}" if lapack_feedback != 0
      x
    end

    protected def each
      (0...@values.size).each do |i|
        yield i, @values[i]
      end
    end

    def square?
      number_of_rows == number_of_cols
    end

    def to_s(io)
      (0...number_of_rows).each do |i|
        io.puts if i > 0
        io << "|"
        (0...number_of_cols).each do |j|
          io << " " << self[i, j] << " "
        end
        io << "|"
      end
    end

    private def lapack_lu(pivot_indices_array)
      info = 0
      LibLapack.lu(
        pointerof(@number_of_rows), # m
        pointerof(@number_of_cols), # n
        self,                       # a
        ld_ptr,                     # lda
        pivot_indices_array,        # ipiv
        pointerof(info)             # info
      )
      info
    end

    private def lapack_invert(pivot_indices_array)
      workspace_length = number_of_rows * number_of_cols
      workspace = Slice.new(workspace_length, 0.0)

      info = 0
      LibLapack.dgetri_(
        pointerof(@number_of_rows),  # n
        self,                        # a
        ld_ptr,                      # lda
        pivot_indices_array,         # ipiv
        workspace,                   # work
        pointerof(workspace_length), # lwork
        pointerof(info)              # info
)
      info
    end

    private def lapack_solve(a, b)
      info = 0
      nhrs = b.number_of_cols
      ldb = b.number_of_rows

      LibLapack.dgesv(
        pointerof(@number_of_rows),   # n
        pointerof(nhrs),              # nhrs
        a,                            # a
        ld_ptr,                       # lda
        Slice.new(number_of_rows, 0), # ipiv
        b,                            # b
        pointerof(ldb),               # ldb
        pointerof(info)               # info
      )
      info
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

    protected def ld
      number_of_rows
    end

    protected def ld_ptr
      pointerof(@number_of_rows)
    end

    def to_unsafe
      values.to_unsafe
    end
  end
end
