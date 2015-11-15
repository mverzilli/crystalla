module Crystalla
  class Matrix
    def mean
      @values.sum / (number_of_rows * number_of_cols)
    end

    def mean_by_row
      means = Array.new(number_of_rows, 0.0)
      number_of_rows.times do |i|
        number_of_cols.times do |j|
          means[i] += self[i, j]
        end
        means[i] = means[i] / number_of_cols
      end
      means
    end

    def mean_by_col
      means = Array.new(number_of_cols, 0.0)
      number_of_cols.times do |j|
        number_of_rows.times do |i|
          means[j] += self[i, j]
        end
        means[j] = means[j] / number_of_rows
      end
      means
    end
  end
end
