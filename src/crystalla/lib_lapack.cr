module Crystalla
  {% if flag?(:darwin) %}
    @[Link(framework: "Accelerate")]
    lib LibLapack
      fun ilaver(major : Int32*, minor : Int32*, patch : Int32*)
      fun lu = dgetrf(m : Int32*, n : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, info : Int32*)
      fun dgetri(n : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, work : Float64*, lwork : Int32*, info : Int32*)
      fun dgesv(n : Int32*, nhrs : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, b : Float64*, ldb : Int32*, info : Int32*)
      fun dgesdd(jobz : Char*, m : Int32*, n : Int32*, a : Float64*, lda : Int32*, s : Float64*, u : Float64*, ldu : Int32*, vt : Float64*, ldvt : Int32*, work : Float64*, lwork : Int32*, iwork : Int32*, info : Int32*)
      {% if flag?(:dgesvdx) %}
        fun dgesvdx(jobu : Char*, jobvt : Char*, range : Char*, m : Int32*, n : Int32*, a : Float64*, lda : Int32*, vl : Float64*, vu : Float64*, il : Int32*, iu : Int32*, ns : Int32*, s : Float64*, u : Float64*, ldu : Int32*, vt : Float64*, ldvt : Int32*, work : Float64*, lwork : Int32*, iwork : Int32*, info : Int32*)
      {% end %}
    end
  {% else %}
    @[Link("lapack")]
    lib LibLapack
      fun ilaver = ilaver_(major : Int32*, minor : Int32*, patch : Int32*)
      fun lu = dgetrf_(m : Int32*, n : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, info : Int32*)
      fun dgetri = dgetri_(n : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, work : Float64*, lwork : Int32*, info : Int32*)
      fun dgesv = dgesv_(n : Int32*, nhrs : Int32*, a : Float64*, lda : Int32*, ipiv : Int32*, b : Float64*, ldb : Int32*, info : Int32*)
      fun dgesdd = dgesdd_(jobz : Char*, m : Int32*, n : Int32*, a : Float64*, lda : Int32*, s : Float64*, u : Float64*, ldu : Int32*, vt : Float64*, ldvt : Int32*, work : Float64*, lwork : Int32*, iwork : Int32*, info : Int32*)
      {% if flag?(:dgesvdx) %}
        fun dgesvdx = dgesvdx_(jobu : Char*, jobvt : Char*, range : Char*, m : Int32*, n : Int32*, a : Float64*, lda : Int32*, vl : Float64*, vu : Float64*, il : Int32*, iu : Int32*, ns : Int32*, s : Float64*, u : Float64*, ldu : Int32*, vt : Float64*, ldvt : Int32*, work : Float64*, lwork : Int32*, iwork : Int32*, info : Int32*)
      {% end %}
    end
  {% end %}
end
