module Crystalla::BlasHelper
  def blas_multiply_matrix(other)
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

  def blas_multiply_array(other)
    number_of_rows = shape[0]
    number_of_cols = shape[1]
    other_number_of_cols = other.shape[1]
    c = self.class.zeros(number_of_rows, other_number_of_cols)
    LibBlas.dgemm(
      LibBlas::Order::ColMajor,                                 # order
      LibBlas::Transpose::NoTrans, LibBlas::Transpose::NoTrans, # transa, transb
      number_of_rows, other_number_of_cols, number_of_cols,     # m, n, k
      1.0, self.values, ld_array,                               # alpha, a, lda
      other.values, other.ld_array,                             # b, ldb
      1.0, c.values, c.ld_array                                 # beta, c, ldc
    )
    if other.shape[0] == 0
      c.reshape(0, other_number_of_cols)
    end
    return c
  end
end
