module Crystalla
  module Comparisons
    RELATIVE_TOLERANCE = 1e-8
    ABSOLUTE_TOLERANCE = 1e-5

    def close_to(other, absolute_tolerance = nil, relative_tolerance = nil)
      absolute_tolerance ||= ABSOLUTE_TOLERANCE
      relative_tolerance ||= RELATIVE_TOLERANCE
      max_diff = absolute_tolerance + relative_tolerance * other.abs
      (self - other).abs <= max_diff
    end
  end
end

struct Float64
  include Crystalla::Comparisons
end

class Array
  def all_close(other, absolute_tolerance = nil, relative_tolerance = nil)
    return false unless self.size == other.size
    self.size.times do |i|
      return false unless self[i].close_to(other[i], absolute_tolerance, relative_tolerance)
    end
    true
  end
end
