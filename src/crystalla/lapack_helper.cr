module Crystalla::LapackHelper
  def lapack_lu!(pivot_indices_array)
    info = 0

    LibLapack.lu(
      pointerof(@number_of_rows), # m
      pointerof(@number_of_cols), # n
      self,                       # a
      ld_ptr,                     # lda
      pivot_indices_array,        # ipiv
      pointerof(info)             # info
    )

    # TODO: handle specific error codes
    if info != 0
      raise "LU failed: code #{info}"
    end
  end

  def lapack_invert!(pivot_indices_array)
    workspace_length = number_of_rows * number_of_cols
    workspace = Slice.new(workspace_length, 0.0)
    info = 0

    LibLapack.dgetri(
      pointerof(@number_of_rows),  # n
      self,                        # a
      ld_ptr,                      # lda
      pivot_indices_array,         # ipiv
      workspace,                   # work
      pointerof(workspace_length), # lwork
      pointerof(info)              # info
    )

    raise "sgetri_ returned an error!" if info != 0
  end

  def lapack_solve(a, b)
    info = 0
    nhrs = b.number_of_cols
    ldb = b.number_of_rows

    LibLapack.dgesv(
      pointerof(@number_of_rows),   # n
      pointerof(nhrs),              # nhrs
      a,                            # a
      ld_ptr,                       # lda
      Slice.new(number_of_rows, 0), # ipiv
      b,                            # b
      pointerof(ldb),               # ldb
      pointerof(info)               # info
    )

    raise "Solve failed: code #{info}" if info != 0
  end

  def lapack_svd(u, s, vt)
    mindim = [@number_of_rows, @number_of_cols].min
    maxdim = [@number_of_rows, @number_of_cols].max

    if u.nil? || vt.nil?
      jobz = 'N'
      lwork = 2 * (3 * mindim + [maxdim, 7 * mindim].max)
    else
      jobz = 'A'
      lwork = 2 * (mindim * (6 + 4 * mindim) + maxdim)
    end

    u ||= Matrix.empty
    vt ||= Matrix.empty
    a = self.clone
    ldu = @number_of_rows
    ldvt = @number_of_cols
    work = Array.new(lwork, 0.0)
    iwork = Array.new(8 * mindim, 0)
    info = 0

    LibLapack.dgesdd(
      pointerof(jobz), # jobz
      ld_ptr,          # m
      nd_ptr,          # n
      a,               # a
      ld_ptr,          # lda
      s,               # s
      u,               # u
      pointerof(ldu),  # ldu
      vt,              # vt
      pointerof(ldvt), # ldvt
      work,
      pointerof(lwork),
      iwork,
      pointerof(info)
    )

    raise "SVD failed: code #{info}" if info != 0
  end

  def ld
    number_of_rows
  end

  def ld_ptr
    pointerof(@number_of_rows)
  end

  def nd_ptr
    pointerof(@number_of_cols)
  end
end
