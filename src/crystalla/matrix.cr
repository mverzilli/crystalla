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
      compare(other) {|index, value| value == other.values[index]}
    end

    def all_close(other)
      compare(other) {|index, value| value.close_to(other.values[index])}
    end

    def compare(other)
      return false unless self.dimensions == other.dimensions

      self.each do |index, value|
        return false unless yield(index, value)
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

    protected def each
      (0...@values.size).each do |i|
        yield i, @values[i]
      end
    end

    # LAPACK calls
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
