require "./ndarray/builders"
require "./transformations/pca"


module Crystalla


  # class Dtype(T)

  #   def initialize
  #   end

  # end

  class Ndarray
    include LapackHelper
    include BlasHelper

    getter values
    getter shape
    setter shape

    @shape : Tuple(Int32, Int32)
    @values : Array(Float64)

    def initialize(values, shape = {0,0})
      @shape = shape
      @shape = set_shape(values) unless shape != {0,0}
      @values = set_values(values)
      #TODO
      #@dtype = set_type(values)
    end


    def self.[](*values : Array(Number)) : Ndarray
      Ndarray.new(values)
    end

    def set_shape(values)
      if values.is_a?(Array(Int32)) ||values.is_a?(Array(Float64))
        return {0, values.size}
      else
        number_of_cols = values.min_by{|v| v.size}.size
        values.each{|v| raise ArgumentError.new("Array #{v} should be of dimension #{number_of_cols}") if v.size != number_of_cols}
        return {values.size, number_of_cols}
      end
    end

    def set_values(values)
      new_values = [] of Float64

      if (values.is_a?(Array(Int32)) ||values.is_a?(Array(Float64)))  # check for 1D array and convert it to Float64 if Int32
        new_values = values.map{|v| v.to_f64}
      else  # check for 2D array and store it in column major order
        (0...shape[1]).each do |i|
          values.each do |v|
            new_values << v[i].to_f64
          end
        end
        return new_values
      end
    end

    def broadcast(number) : Ndarray
      number = number.to_f64
      if shape[0] != 0
        other = Ndarray.tile(Array.new(@shape[1], number), @shape[0])
      else
        other = Ndarray.new(Array.new(@shape[1], number))
      end
      return other
    end

    def +(other : self) : Ndarray
      zip_with(other) { |x, y| x + y }
    end

    # brodcasting for addition
    def +(number : Number) : Ndarray
      other = broadcast(number)
      zip_with(other) { |x, y| x + y }
    end

    # element wise multiplication
    def *(other : self) : Ndarray
      zip_with(other) { |x, y| x * y }
    end

    # broadcasting for multiplication
    def *(number : Number) : Ndarray
      other = broadcast(number)
      zip_with(other) { |x, y| x * y }
    end


    def -(other : self) : Ndarray
      zip_with(other) { |x, y| x - y }
    end

    # broadcasting for substracion
    def -(number : Number) : Ndarray
      other = broadcast(number)
      zip_with(other) { |x, y| x - y }
    end

    def /(other : self) : Ndarray
      zip_with(other) { |x, y| x / y }
    end

    # broadcasting for division
    def /(number : Number) : Ndarray
      other = broadcast(number)
      zip_with(other) { |x, y| x / y }
    end

    def - : Ndarray
      Ndarray.new(values.map(&.-), @shape)
    end

    # element wise square root
    def sqrt
      result = self.values.map{|v| Math.sqrt(v)}
      Ndarray.new(result, shape)
    end

    def exp
      result = self.values.map{|v| Math.exp(v)}
      Ndarray.new(result, shape)
    end

    def zip_with(other) : Ndarray
      # expand rows & columns
      if shape[1] == 1 && (other.shape[0] == 1 || other.shape[0] == 0)
        other = Ndarray.tile(other.values, @shape[0].to_i32)
        self_values = [] of Float64
        (1...self.shape[0]).each do |i|
          self_values += self.values
        end
        expand_self = Ndarray.new(self_values, {shape[0], other.shape[1]})
        new_values = Array.new(expand_self.values.size, 0.0)
        expand_self.each do |i, x|
          new_values[i] = yield x, other.values[i]
        end
        return Ndarray.new(new_values, expand_self.shape)

      # expand rows
      elsif shape[0] != other.shape[0] && (other.shape[0] == 1 || other.shape[0] == 0)
        other = Ndarray.tile(other.values, @shape[0])
      elsif shape[0] != other.shape[0]
        raise ArgumentError.new "number of rows mismatch in array operation"
      end


      # expand columns
      if shape[1] != other.shape[1] && other.shape[1] == 1
        other_values = [] of Float64
        (0..other.shape[0]).each do |i|
          other_values += other.values
        end
        other = Ndarray.new(other_values, {shape[0], shape[1]})
      elsif shape[1] != other.shape[1]
        raise ArgumentError.new "number of columns mismatch in array operation"
      end

      new_values = Array.new(@values.size, 0.0)
      self.each do |i, x|
        new_values[i] = yield x, other.values[i]
      end
      Ndarray.new(new_values, shape)
    end

    # sum elements of the whole array, or following an axis
    def sum(axis = nil)
      if axis.nil?
        self.values.reduce{ |acc, i| acc + i }
      elsif axis == 0
        arr = self.values.in_groups_of(shape[1])
        sum = arr.map{|v| v.compact.sum(0.0)}.flatten
        Ndarray.new(sum)
      elsif axis == 1
        sum = [] of Float64
        self.each_row{|r| sum << r.sum}
        Ndarray.new(sum)
      else
        raise ArgumentError.new "Axis provided must be 0(columns) or 1(rows)"
      end
    end

    # "dot product": multiplication or arrays
    def dot (other : self) : Ndarray
      if other.shape[0] == 0 && shape[1] != other.shape[1]
        raise ArgumentError.new "number of rows/columns mismatch in array multiplication"
      elsif other.shape[0] != 0 && shape[1] != other.shape[0]
        raise ArgumentError.new "number of rows/columns mismatch in array multiplication"
      end

      blas_multiply_array other
    end

    # reshape array C style or Fortran style
    def reshape(number_of_rows, number_of_cols, order="F")
      if order == "C"
        @shape = {number_of_rows, number_of_cols}
        return self.transpose
      else
        @shape = {number_of_rows, number_of_cols}
      end
      return self
    end

    def [](index)
      raise ArgumentError.new("A row number an column number should be provided") if shape[0] != 0
      values[index]
    end

    def [](row, col) : Float64
      values[row_col_to_index(row, col)]
    end

    def []=(row : Int32, col : Int32, value : Number)
      values[row_col_to_index(row, col)] = value.to_f64
    end

    def []=(index : Int32, value : Number)
      values[index] = value.to_f64
    end

    def slice(rows : Tuple(Int32, Int32), cols : Tuple(Int32, Int32))
      # interprete negative numbers as a count from the end of the dimension
      if rows[1] < 0
        rows = {rows[0], shape[0] + rows[1]}
      end

      if cols[1] < 0
        cols = {cols[0], shape[1] + cols[1]}
      end

      raise ArgumentError.new("out of bounds") unless in_bounds?(rows, cols)

      sliced_array = [] of Float64
      (rows[0]...rows[1]).each do |i|
        (cols[0]...cols[1]).each do |j|
          sliced_array << self[i, j]
        end
      end
      arr = Ndarray.new(sliced_array)
      number_of_rows = rows[1] - rows[0]
      number_of_cols = cols[1] - cols[0]
      arr.shape = {number_of_rows, number_of_cols}
      if number_of_rows == 1
        return arr
      else
        return arr.transpose
      end
    end

    def > (num : Number)
      bool_comparison(num) {|v, num| v > num ? 1 : 0}
    end

    def < (num : Number)
      bool_comparison(num) {|v, num| v < num ? 1 : 0}
    end

    def == (num : Number)
      bool_comparison(num) {|v, num| v == num ? 1 : 0}
    end

    private def bool_comparison(num)
      res = self.values.map{|v| yield v, num}
      arr = Ndarray.new(res, shape)
    end

    def ==(other : Ndarray) : Bool
      compare(other) { |index, value| value == other.values[index] }
    end


    def compare(other : Ndarray) : Bool
      return false unless self.shape == other.shape

      self.each do |index, value|
        return false unless yield(index, value)
      end

      true
    end

    def self.validate_dimensions(number_of_rows, number_of_cols)
      if number_of_rows < 0
        raise ArgumentError.new "negative number of rows"
      end

      if number_of_cols < 0
        raise ArgumentError.new "negative number of columns"
      end
    end

    protected def each
      (0...@values.size).each do |i|
        yield i, @values[i]
      end
    end

    def each_row
      (0...@shape[0]).each do |i|
        row = [] of Float64
        (0...@shape[1]).each do |j|
          row.push self[i, j]
        end
        yield row, i
      end
    end

    def each_col
      i = 0
      @values.each_slice(@shape[0]) do |col|
        yield col.dup, i
        i += 1
      end
    end

    def each_by_row
      (0...@shape[0]).each do |i|
        (0...@shape[1]).each do |j|
          yield self[i, j], i, j
        end
      end
    end

    def each_by_col
      (0...@shape[1]).each do |j|
        (0...@shape[0]).each do |i|
          yield self[i, j], i, j
        end
      end
    end

    def clone : Ndarray
      arr = Ndarray.new(@values.clone, @shape)
    end

    def square? : Bool
      shape[0] == shape[1]
    end

    def transpose : Ndarray
      transposed = Ndarray.new(Array.new(@values.size, 0.0))
      transposed.shape = {@shape[1], @shape[0]}
      each_by_col do |val, i, j|
        transposed[j, i] = val
      end
      transposed
    end

    # Returns the sum of the diagonal elements. Only useful for numeric matrices.
    def trace : Float64
      raise ArgumentError.new "Number of rows (#{shape[0]}) does not match number of columns (#{shape[1]})" unless square?
      (0...shape[0]).sum(0.0) { |i| self[i, i] }
    end

    def row_vector? : Bool
      @shape[0] == 1
    end

    def insert(index : Int32, element : Int32)
      new_values = [] of Float64
      new_values += @values
      new_values.insert(index, element.to_f64)
      Ndarray.new(new_values)
    end

    def prepend(element : Number) : Ndarray
      insert(0, element)
    end

    def append(element : Number) : Ndarray
      insert(@shape[1], element)
    end

    def prepend(row : Ndarray) : Ndarray
      add_rows(0, row)
    end

    def append(row : Ndarray) : Ndarray
      add_rows(@shape[0], row)
    end

    def add_rows(index : Int32, rows : Ndarray) : Ndarray
      new_rows = [] of Array(Float64)
      insert_rows = ->{ rows.each_row { |row, row_index| new_rows.push row } }

      each_row do |row, row_index|
        insert_rows.call if index == row_index
        new_rows.push row
      end

      insert_rows.call if index >= @shape[0]

      Ndarray.new(new_rows)
    end

    def all_close(other : Ndarray, absolute_tolerance = nil, relative_tolerance = nil) : Bool
      compare(other) { |index, value| value.close_to(other.values[index], absolute_tolerance, relative_tolerance) }
    end

    private def row_col_to_index(row, col)
      shape[0] * col + row
    end

    def inspect(io)
      to_s(io)
    end

    def to_s(io)
      # We traverse all numbers to find out, per each column:
      # - The maximum number of digits to the left of the dot
      # - The maximum number of digits to the right of the dot
      infos = Array.new(shape[1], {0, 0})

      # While we traverse the values we collect the resulting strings,
      # together with left/right info
      strings = Array.new(values.size, {"", 0, 0})

      shape[1].times do |col|
        current = {0, 0}

        shape[0].times do |row|
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
      io << "["
      if shape[0] == 0
        shape[1].times do |j|
          io <<  ", " if j > 0
          io << values[j]
        end
      else
        shape[0].times do |i|
          if i > 0
            io << ","
            io.puts
            io << " "
          end
          io << "[ "
          shape[1].times do |j|
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
      end
      io << "]"
    end

    private def in_bounds?(rows, cols) : Bool
      if rows[1] > @shape[0]
        raise ArgumentError.new("requested rows are out of bounds")
      end

      if cols[1] > @shape[1]
        raise ArgumentError.new("requested cols are out of bounds")
      end

      return true
    end


    def to_unsafe
      values.to_unsafe
    end
  end
end












