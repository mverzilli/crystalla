module Crystalla
  module Comparisons
    RELATIVE_TOLERANCE = 1e-8
    ABSOLUTE_TOLERANCE = 1e-5

    def close_to(other)
      max_diff = ABSOLUTE_TOLERANCE + RELATIVE_TOLERANCE * other.abs
      (self - other).abs <= max_diff
    end
  end
end

struct Float64
  include Crystalla::Comparisons
end
