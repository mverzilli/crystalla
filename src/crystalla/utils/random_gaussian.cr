require "../ndarray"

module Crystalla
  class RandomGaussian
    @g1 : Float64
    @g0 : Float64

    def initialize(mean = 0.0, sd = 1.0, rng = Random.rand)
      @mean, @sd, @rng = mean, sd, rng
      @compute_next_pair = false
      @g1 = 0.0
      @g0 = 0.0
    end

    def rand_array(rows = 0, cols = 0)
       Crystalla::Ndarray.new(Array.new(rows*cols, Crystalla::RandomGaussian.new.rand), {rows, cols})
    end

    def rand
      if (@compute_next_pair = !@compute_next_pair)
        theta = 2 * Math::PI * @rng
        scale = @sd * Math.sqrt(-2 * Math.log(1 - @rng))
        @g1 = @mean + scale * Math.sin(theta)
        @g0 = @mean + scale * Math.cos(theta)
      else
        @g1
      end
    end
  end
end
