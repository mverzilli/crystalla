module Crystalla
  class Ndarray

    # element wise square root
    def sqrt
      result = self.values.map{|v| Math.sqrt(v)}
      Ndarray.new(result, shape)
    end

    # element wise exp
    def exp
      result = self.values.map{|v| Math.exp(v)}
      Ndarray.new(result, shape)
    end

    # element wise sigmoid
    def sigmoid
      return ((-self).exp + 1) ** -1
    end
  end
end








