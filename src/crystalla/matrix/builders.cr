module Crystalla
  class Matrix
    def self.columns(columns : Array(Array(Float64))) : Crystalla::Matrix
      check_columns_have_same_number_of_rows columns
      Crystalla::Matrix.new columns.flatten, columns.first.size, columns.size
    end

    def self.columns(columns : Array(Array(Number))) : Crystalla::Matrix
      Crystalla::Matrix.columns columns.map(&.map(&.to_f))
    end

    def self.load(file : String) : Crystalla::Matrix
      rows = [] of Array(Float64)
      File.each_line(file) do |line|
        rows.push line.split.map(&.to_f)
      end
      Crystalla::Matrix.rows rows
    end

    def self.rows(rows : Array(Array(Number)))
      check_rows_have_same_number_of_rows rows
      Crystalla::Matrix.columns rows.transpose
    end

    def self.zeros(number_of_rows : Int32, number_of_cols : Int32) : Crystalla::Matrix
      self.constant_matrix(0, number_of_rows, number_of_cols)
    end

    def self.ones(number_of_rows : Int32, number_of_cols : Int32) : Crystalla::Matrix
      self.constant_matrix(1, number_of_rows, number_of_cols)
    end

    def self.constant_matrix(value : Number, number_of_rows : Int32, number_of_cols : Int32) : Crystalla::Matrix
      validate_dimensions(number_of_rows, number_of_cols)
      Crystalla::Matrix.new(Array.new(number_of_rows * number_of_cols, value.to_f), number_of_rows, number_of_cols)
    end

    def self.rand_perm(n : Int32) : Crystalla::Matrix
      raise ArgumentError.new("rand_perm given size must be greater than 0") if n <= 0
      Crystalla::Matrix.row_vector (0...n).to_a.shuffle
    end

    def self.row_vector(values : Array(Number)) : Crystalla::Matrix
      Crystalla::Matrix.rows [values]
    end

    def self.empty : Crystalla::Matrix
      Crystalla::Matrix.new(Array.new(0, 0.0), 0, 0)
    end

    def self.rand(number_of_rows : Int32, number_of_cols : Int32) : Crystalla::Matrix
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.next_float
      end

      Crystalla::Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.rand(number_of_rows : Int32, number_of_cols : Int32, range : Range(Int32, Int32)) : Crystalla::Matrix
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.rand(range).to_f
      end

      Crystalla::Matrix.new(values, number_of_rows, number_of_cols)
    end

    def self.diag(diagonal : Array(Number)) : Crystalla::Matrix
      diag(diagonal, diagonal.size, diagonal.size)
    end

    def self.diag(diagonal : Array(Number), number_of_rows : Int32, number_of_cols : Int32) : Crystalla::Matrix
      m = self.zeros(number_of_rows, number_of_cols)
      diagonal.each_with_index do |x, i|
        break if i >= number_of_rows || i >= number_of_cols
        m[i, i] = x
      end
      return m
    end

    def self.eye(number_of_rows_and_cols : Int32) : Crystalla::Matrix
      eye(number_of_rows_and_cols, number_of_rows_and_cols)
    end

    def self.eye(number_of_rows : Int32, number_of_cols : Int32) : Crystalla::Matrix
      validate_dimensions(number_of_rows, number_of_cols)

      values = Array.new(number_of_rows * number_of_cols, 0.0)
      [number_of_cols, number_of_rows].min.times do |i|
        values[number_of_rows * i + i] = 1.0
      end

      Crystalla::Matrix.new(values, number_of_rows, number_of_cols)
    end
  end
end
