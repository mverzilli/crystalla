module Crystalla
  class Matrix
    property number_of_rows
    property number_of_cols
    property values

    protected def initialize(@values, @number_of_rows, @number_of_cols); end

    def self.columns(columns : Array(Array(Float64)))
      Matrix.new columns.flatten, columns.first.size, columns.size
    end

    def self.load(file)
      rows = [] of Array(Float64)
      File.each_line(file) do |line|
        rows.push line.split.map(&.to_f)
      end
      Matrix.columns rows.transpose
    end

    def dimensions
      {number_of_rows, number_of_cols}
    end

    def print
      (0...@number_of_rows).each do |i|
        row = "|"
        (0...@number_of_cols).each do |j|
          row += " #{self[i, j]} "
        end
        row += "|"
        p row
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
      @values[@number_of_rows * j + i]
    end

    def invert!
      pivot_indices_array = Array.new(@number_of_rows, 0)
      lapack_feedback = lapack_lu(pivot_indices_array)
      raise "LU failed: code #{lapack_feedback}" if lapack_feedback != 0
      lapack_feedback = lapack_invert(pivot_indices_array)
      raise "sgetri_ returned an error!" if lapack_feedback != 0
      self
    end

    private def lapack_lu(pivot_indices_array)
      info = 0
      LibLapack.lu(
        pointerof(@number_of_rows),
        pointerof(@number_of_cols),
        @values.to_unsafe as Void*,
        pointerof(@number_of_rows),
        pivot_indices_array,
        pointerof(info)
      )
      info
    end

    private def lapack_invert(pivot_indices_array)
      workspace_length = @number_of_rows * @number_of_cols
      workspace = Slice.new(workspace_length, 0.0)

      info = 0
      LibLapack.dgetri_(
        pointerof(@number_of_rows),
        @values.to_unsafe as Void*,
        pointerof(@number_of_rows),
        pivot_indices_array,
        workspace.to_unsafe as Void*,
        pointerof(workspace_length),
        pointerof(info)
      )
      info
    end
  end
end
