module Crystalla
  class Ndarray
    def self.zeros(number_of_rows : Int32, number_of_cols : Int32) : Ndarray
      self.constant_array(0.0, number_of_rows, number_of_cols)
    end

    def self.ones(number_of_rows : Int32, number_of_cols : Int32) : Ndarray
      self.constant_array(1.0, number_of_rows, number_of_cols)
    end

    def self.full(number_of_rows : Int32, number_of_cols : Int32, value : Number) : Ndarray
      constant_array(value, number_of_rows, number_of_cols)
    end

    def self.constant_array(value : Number, number_of_rows : Int32, number_of_cols : Int32) : Ndarray
      validate_dimensions(number_of_rows, number_of_cols)
      arr = Ndarray.new(Array.new(number_of_rows * number_of_cols, value))
      arr.shape = {number_of_rows,number_of_cols}
      return arr
    end

    def self.eye(number_of_rows_and_cols : Int32) : Ndarray
      eye(number_of_rows_and_cols, number_of_rows_and_cols)
    end

    def self.eye(number_of_rows : Int32, number_of_cols : Int32) : Ndarray
      validate_dimensions(number_of_rows, number_of_cols)

      values = Array.new(number_of_rows * number_of_cols, 0.0)
      [number_of_cols, number_of_rows].min.times do |i|
        values[number_of_rows * i + i] = 1.0
      end

      arr = Ndarray.new(values)
      arr.shape = {number_of_rows, number_of_cols}
      return arr
    end

    def self.tile(vector : Array, count : Int32)
      array = [] of Array(Float64)
      (0...count).each do |i|
        array << vector
      end
      Ndarray.new(array)
    end

    def self.rand(number_of_rows : Int32, number_of_cols : Int32) : Ndarray
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.next_float
      end

      arr = Ndarray.new(values)
      arr.shape = {number_of_rows, number_of_cols}
      return arr
    end

    def self.rand(number_of_rows : Int32, number_of_cols : Int32, range : Range(Int32, Int32)) : Ndarray
      validate_dimensions(number_of_rows, number_of_cols)

      r = Random.new
      values = Array.new(number_of_rows * number_of_cols, 0.0)
      values.size.times do |i|
        values[i] = r.rand(range).to_f
      end

      arr = Ndarray.new(values)
      arr.shape = {number_of_rows, number_of_cols}
      return arr
    end

  end
end
