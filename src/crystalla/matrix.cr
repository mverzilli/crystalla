module Crystalla
  class Matrix
    property number_of_rows
    property number_of_cols
    property values

    protected def initialize(@values, @number_of_rows, @number_of_cols); end

    def self.columns(columns : Array(Array(Float64)))
      Matrix.new columns.flatten, columns.first.size, columns.size
    end

    def dimensions
      {number_of_rows, number_of_cols}
    end

    def print
      (0...m.number_of_rows).each do |i|
        row = "|"
        (0...m.number_of_cols).each do |j|
          row += " #{m[i, j]} "
        end
        row += "|"
      end
    end

    # *Heavily inspired* by:
    # http://docs.scipy.org/doc/numpy/reference/generated/numpy.allclose.html
    def all_close(other)
      return false unless self.dimensions == other.dimensions

      (0...@values.size).each do |i|
        return false unless @values[i].close_to(other.values[i])
      end

      true
    end

    def [](i, j)
      @values[@number_of_cols * j + i]
    end

    def invert!
      # Set the dimension of the "workspace" array WORK
      # see http://www.netlib.org/lapack-dev/lapack-coding/program-style.html#workspace
      # TODO: calculate the workspace size dinamically
      lwork = 100
      work = Array.new(lwork, 0_f32)

      # TODO: check that the assumption ipiv = rows * cols is right
      # Pivot indices array
      ipiv = Array.new(@number_of_rows * @number_of_cols, 0)

      # Lapack error codes
      info = 0

      # Calculate LU decomposition of A (and store it in A)
      LibLapack.lu(
        pointerof(@number_of_rows),
        pointerof(@number_of_cols),
        @values.to_unsafe as Void*,
        pointerof(@number_of_rows),
        ipiv,
        pointerof(info)
      )

      raise "LU failed" if info != 0

      LibLapack.dgetri_(
        pointerof(@number_of_rows),
        @values.to_unsafe as Void*,
        pointerof(@number_of_rows),
        ipiv,
        pointerof(work) as Void*,
        pointerof(lwork),
        pointerof(info)
      )

      raise "sgetri_ returned an error!" if info != 0

      self
    end
  end
end
