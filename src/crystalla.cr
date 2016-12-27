require "./crystalla/*"
require "benchmark"
module Crystalla
  def self.lapack_version
    major = 0
    minor = 0
    patch = 0
    LibLapack.ilaver(pointerof(major), pointerof(minor), pointerof(patch))
    {major, minor, patch}
  end

  def self.display_info!
    puts "Using LAPACK version #{Crystalla.lapack_version.to_a.join('.')}"
  end
end
