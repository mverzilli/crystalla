require "./crystalla/*"

module Crystalla
  def self.lapack_version
    major :: Int32
    minor :: Int32
    patch :: Int32
    LibLapack.ilaver(pointerof(major), pointerof(minor), pointerof(patch))
    {major, minor, patch}
  end

  def self.display_info!
    puts "Using LAPACK version #{Crystalla.lapack_version.to_a.join('.')}"
  end
end
