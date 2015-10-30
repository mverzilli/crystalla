module Crystalla::BlasHelper
  def blas_multiply(other)
    c = self.class.zeros(number_of_rows, other.number_of_cols)
    LibBlas.dgemm(
      LibBlas::Order::ColMajor,                                 # order
      LibBlas::Transpose::NoTrans, LibBlas::Transpose::NoTrans, # transa, transb
      number_of_rows, other.number_of_cols, number_of_cols,     # m, n, k
      1.0, self, ld,                                            # alpha, a, lda
      other, other.ld,                                          # b, ldb
      1.0, c, c.ld                                              # beta, c, ldc
    )
    c
  end
end
