require "benchmark"
require "./src/crystalla"
cols = [] of Array(Float64)
range = 1000
r = Random.new
(1..range).each do |i|
  row = [] of Float64
  (1..range).each do |j|
    row.push r.next_float
  end
  cols.push row
end

m = Crystalla::Matrix.columns cols
# m.print

# p Benchmark.realtime { Crystalla::Matrix.columns([[1.0,3.0], [2.0,2.0]]).invert! }
p Benchmark.realtime { m.invert! }
