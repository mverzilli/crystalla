module Crystalla
  @[Link(framework: "Accelerate")]
  lib LibLapack
    fun lu = dgetrf_(m: Int32*, n: Int32*, a: Void*, lda: Int32*, ipiv: Int32*, info: Int32*)
    fun dgetri_(n: Int32*, a: Void*, lda: Int32*, ipiv: Int32*, work: Void*, lwork: Int32*, info: Int32*)
  end
end
