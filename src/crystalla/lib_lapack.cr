module Crystalla
  @[Link(framework: "Accelerate")]
  lib LibLapack
    fun lu = dgetrf_(m : Int32*, n : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, info : Int32*)
    fun dgetri_(n : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, work : Float64*, lwork : Int32*, info : Int32*)
    fun dgesv(n : Int32*, nhrs : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, b : Float64*, ldb : Int32*, info : Int32*)
    fun dgesdd(jobz : Char*, m : Int32*, n : Int32*, a : Float64*, lda : Int32*, s : Float64*, u : Float64*, ldu : Int32*, vt : Float64*, ldvt : Int32*, work : Float64*, lwork : Int32*, iwork : Int32*, info : Int32*)
  end
end
