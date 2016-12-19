module Crystalla
  {% if flag?(:darwin) %}
    @[Link(framework: "Accelerate")]
  {% else %}
    @[Link("blas")]
  {% end %}
  lib LibBlas
    enum Order
      RowMajor = 101
      ColMajor = 102
    end

    enum Transpose
      NoTrans   = 111
      Trans     = 112
      ConjTrans = 113
    end

    fun dgemm = cblas_dgemm(order : Order, transa : Transpose, transb : Transpose, m : Int32, n : Int32, k : Int32, alpha : Float64, a : Float64*, lda : Int32, b : Float64*, ldb : Int32, beta : Float64, c : Float64*, ldc : Int32)
  end
end
