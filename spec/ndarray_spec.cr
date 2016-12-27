require "./spec_helper"
require "benchmark"

describe Ndarray do
  context "creation" do
    it "creates a Ndarray from given columns" do
      m = Ndarray.new([[1, 3], [2, 4]]).transpose

      m[0, 0].should eq(1)
      m[0, 1].should eq(2)
      m[1, 0].should eq(3)
      m[1, 1].should eq(4)
    end

    it "creates a Matrix from given rows" do
      m = Ndarray.new([
        [1, 2],
        [3, 4],
      ])

      m[0, 0].should eq(1)
      m[0, 1].should eq(2)
      m[1, 0].should eq(3)
      m[1, 1].should eq(4)
    end

    it "raises on dimension mismatch" do
      expect_raises ArgumentError, "Array [2, 4, 5] should be of dimension 2" do
        Ndarray.new([[1, 3], [2, 4, 5]])
      end
    end

    it "creates an array of zeros" do
      m = Ndarray.zeros(1, 2)
      m.shape.should eq({1, 2})
      m[0, 0].should eq(0)
      m[0, 1].should eq(0)
    end

    it "creates a matrix of ones" do
      m = Ndarray.ones(1, 2)
      m.shape.should eq({1, 2})
      m[0, 0].should eq(1)
      m[0, 1].should eq(1)
    end

    it "creates a square identity matrix" do
      m = Ndarray.eye(2)
      m.shape.should eq({2, 2})
      m.should eq(Ndarray.new([[1.0, 0.0], [0.0, 1.0]]))
    end

    it "creates an identity matrix with more rows" do
      m = Ndarray.eye(3, 2)
      m.shape.should eq({3, 2})
      m.should eq(Ndarray.new([[1.0, 0.0], [0.0, 1.0], [0.0, 0.0]]))
    end

    it "creates an identity matrix with more cols" do
      m = Ndarray.eye(2, 3)
      m.shape.should eq({2, 3})
      m.should eq(Ndarray.new([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]]))
    end

    it "creates a row vector given an array" do
      m = Ndarray.new [3, 2, 1]
      m.shape.should eq({0, 3})
      [3, 2, 1].each_with_index { |val, index| val.should eq m[index] }
    end


    it "raises if zeros gets negative rows or cols" do
      expect_raises ArgumentError, "negative number of rows" do
        Ndarray.zeros(-1, 2)
      end

      expect_raises ArgumentError, "negative number of columns" do
        Ndarray.zeros(1, -1)
      end
    end

    it "creates a random matrix" do
      m = Ndarray.rand(2, 3)
      m.shape.should eq({2, 3})
      m.values.each do |value|
        (0.0 <= value <= 1.0).should be_true
      end
    end

    it "creates a random matrix with integer values" do
      m = Ndarray.rand(2, 3, (10..20))
      m.shape.should eq({2, 3})
      m.values.each do |value|
        (10 <= value <= 20).should be_true
        (value - value.to_i).should be_close(0, 0.0000001)
      end
    end


    it "creates with #[]" do
      m = Ndarray[
        [1, 2],
        [3, 4],
      ]

      m[0, 0].should eq(1)
      m[0, 1].should eq(2)
      m[1, 0].should eq(3)
      m[1, 1].should eq(4)
    end


  context "shape" do
    it "with same number of cols and rows" do
      m = Ndarray[[1, 3], [2, 4]]
      m.transpose.shape.should eq({2, 2})
    end

    it "with different number of cols and rows" do
      m = Ndarray[[1, 3], [2, 4], [1, 3], [2, 4]]
      m.transpose.shape.should eq({2, 4})
    end
  end

  context "comparison" do
    it "checks two matrices are equal" do
      m = Ndarray [[1.0, 3.0], [2.0, 4.0]]
      m2 = Ndarray [[1.0, 3.0], [2.0, 4.0]]

      m.should eq(m2)
    end

    it "checks two matrices are not equal" do
      m = Ndarray [[1.0, 3.0], [2.0, 4.0]]
      m2 = Ndarray [[3.0, 3.0], [2.0, 4.0]]

      m.should_not eq(m2)
    end

    it "with similar matrices" do
      m = Ndarray [[1, 3], [2, 4]]
      m2 = Ndarray [[1, 3], [2, 4]]
      m.all_close(m2).should be_true
    end

    it "with matrices with different shape" do
      m = Ndarray [[1, 3], [2, 4]]
      m2 = Ndarray [[1, 3], [2, 4], [3, 5]]
      m.all_close(m2).should be_false
    end

    it "with matrices with same shape and different values" do
      m = Ndarray [[1, 3], [2, 4]]
      m2 = Ndarray [[1, 5], [2, 4]]
      m.all_close(m2).should be_false
    end
  end

#   context "invert" do
#     it "inverts a Matrix" do
#       m = Matrix.columns [[1, 3], [2, 4]]
#       inverse = Matrix.columns [[-2, 1.5], [1, -0.5]]

#       m.invert!.should be_all_close(inverse)
#     end

#     it "raises if non-square" do
#       m = Matrix.columns [[1, 3], [2, 4], [5, 6]]
#       expect_raises ArgumentError, "can't invert non-square matrix" do
#         m.invert!
#       end
#     end
#   end

  context "dot product" do
    it "mutliplies two arrays" do
      m1 = Ndarray.new [
        [1, 2],
        [3, 4],
        [5, 6],
      ]
      m2 = Ndarray.new [
        [7, 8, 9],
        [10, 11, 12],
      ]
      expected = Ndarray.new [
        [1 * 7 + 2 * 10, 1 * 8 + 2 * 11, 1 * 9 + 2 * 12],
        [3 * 7 + 4 * 10, 3 * 8 + 4 * 11, 3 * 9 + 4 * 12],
        [5 * 7 + 6 * 10, 5 * 8 + 6 * 11, 5 * 9 + 6 * 12],
      ]
      (m1.dot(m2)).should eq(expected)
    end

    it "raises if rows don't match columns" do
      m1 = Ndarray.new [
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7],
        [8],
        [9],
      ]
      expect_raises ArgumentError, "number of rows/columns mismatch in array multiplication" do
        m1.dot(m2)
      end
    end
  end

  context "+" do
    it "adds two matrices" do
      m1 = Ndarray.new [
        [1, 2],
        [3, 4],
        [5, 6],
      ]
      m2 = Ndarray.new [
        [7, 8],
        [9, 10],
        [11, 12],
      ]
      expected = Ndarray.new [
        [8, 10],
        [12, 14],
        [16, 18],
      ]
      (m1 + m2).should be_all_close(expected)
    end

    it "raises if rows don't match" do
      m1 = Ndarray.new [
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7, 8],
        [8, 9],
      ]
      expect_raises ArgumentError do
        m1 + m2
      end
    end

    it "raises if cols don't match" do
      m1 = Ndarray.new [
        [1, 2],
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7, 8, 10],
        [8, 9, 10],
      ]
      expect_raises ArgumentError do
        m1 + m2
      end
    end
  end

  context "-" do
    it "substracts two matrices" do
      m1 = Ndarray.new [
        [1, 2],
        [3, 4],
        [5, 6],
      ]
      m2 = Ndarray.new [
        [7, 8],
        [9, 10],
        [11, 12],
      ]
      expected = Ndarray.new [
        [6, 6],
        [6, 6],
        [6, 6],
      ]
      (m2 - m1).should eq(expected)
    end

    it "raises if rows don't match" do
      m1 = Ndarray.new [
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7, 8],
        [8, 9],
      ]
      expect_raises ArgumentError do
        m1 - m2
      end
    end

    it "raises if cols don't match" do
      m1 = Ndarray.new [
        [1, 2],
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7, 8, 10],
        [8, 9, 10],
      ]
      expect_raises ArgumentError do
        m1 - m2
      end
    end
  end

  context "unary -" do
    it "negates a matrix" do
      m = Ndarray.new([[1.0, 2.0], [-3.0, -4.0]])
      expected = Ndarray.new([[-1.0, -2.0], [3.0, 4.0]])
      (-m).should be_all_close(expected)
      m.should be_all_close(Ndarray.new([[1.0, 2.0], [-3.0, -4.0]]))
    end
  end

  context "add rows" do
    it "adds a row at the beginning" do
      m = Ndarray.new([[1.0, 3.0], [2.0, 4.0]])
      new_row = Ndarray.ones 1, 2

      new_m = m.transpose.prepend(new_row)

      new_m.should eq(Ndarray.new([[1.0, 1.0, 3.0], [1.0, 2.0, 4.0]]).transpose)
    end

    it "adds rows from another Matrix at the middle" do
      m = Ndarray.new([[1.0, 3.0], [2.0, 4.0]]).transpose
      new_rows = Ndarray.constant_array 1.0, 2, 2

      new_m = m.add_rows(1, new_rows)

      new_m.should eq(Ndarray.new([[1.0, 1.0, 1.0, 3.0], [2.0, 1.0, 1.0, 4.0]]).transpose)
    end

    it "adds a row at the middle" do
      m = Ndarray.new([[1.0, 3.0], [2.0, 4.0]]).transpose
      new_row = Ndarray.ones 1, 2

      new_m = m.add_rows(1, new_row)

      new_m.should eq(Ndarray.new([[1.0, 1.0, 3.0], [2.0, 1.0, 4.0]]).transpose)
    end

    it "adds a Matrix that's a row vector at the middle" do
      m = Ndarray.new([[1.0, 3.0], [2.0, 4.0]]).transpose
      new_row = Ndarray.ones(1, m.shape[1])

      new_m = m.add_rows(1, new_row)
      new_m.should eq(Ndarray.new([[1.0, 1.0, 3.0], [2.0, 1.0, 4.0]]).transpose)
    end

    it "adds a row at the bottom" do
      m = Ndarray.new([[1.0, 3.0], [2.0, 4.0]]).transpose
      new_row = Ndarray.ones 1, 2

      new_m = m.append(new_row)

      new_m.should eq(Ndarray.new([[1.0, 3.0, 1.0], [2.0, 4.0, 1.0]]).transpose)
    end
  end

  context "clone" do
    it "clones an array" do
      m = Ndarray.new([[1.0, 3.0], [2.0, 4.0]]).transpose
      m2 = m.clone
      m[0, 0] = 1.1

      m[0, 0].should eq(1.1)
      m2[0, 0].should eq(1.0)
    end
  end

  context "transpose" do
    it "transposes" do
      m = Ndarray.new [[1, 2, 3], [3, 2, 1]]
      m.transpose.should eq(Ndarray.new([[1, 2, 3], [3, 2, 1]]).transpose)
    end
  end


  context "trace" do
    it "computes trace for floats" do
      m = Ndarray.new([[1.1, 2.2, 3.3], [4.4, 5.5, 6.6], [7.7, 8.8, 9.9]])
      m.trace.should eq(16.5) # 1.1 + 5.5 + 9.9
    end

    it "raises an error when matrix isn't square" do
      a = Ndarray.new([[1, 2, 3, 4], [5, 6, 7, 8]])
      expect_raises ArgumentError, "Number of rows (2) does not match number of columns (4)" do
        a.trace
      end
    end
  end


  context "observers (as in Algebraic Data Types, not the pattern!)" do
    it "row_vector?" do
      m1 = Ndarray.new [[1, 1], [2, 2]]
      m2 = Ndarray.new [[1, 1, 2, 2]]
      m1.row_vector?.should be_false
      m2.row_vector?.should be_true
    end
  end

  context "each_row" do
    it "yields each row as an Array(Float64)" do
      m_rows = [[1.0, 1.0], [2.0, 2.0]] of Array(Float64)
      m = Ndarray.new m_rows

      m_each_row_result = [] of Array(Float64)
      m.each_row { |row, index| m_each_row_result.push row }

      m_rows.should eq(m_each_row_result)

      # This is to ensure that we're yielding row copies
      m_each_row_result[0][0] = 23.0
      m[0, 0].should eq(1)
    end
  end

  context "submatrices" do
      m = Ndarray.new [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ]

      it "returns a submatrix" do
        m.slice({0,2},{0,2}).should eq(Ndarray.new [[1, 2], [4, 5]])
      end

      it "interprets negatives as a count from the end of the dimension" do
        m.slice({1, -1}, {1, -1}).should eq(Ndarray.new [[5]])
      end

      it "raises if out of bounds" do
        expect_raises ArgumentError do
          m.slice({0,4}, {0,4})
        end
      end

      it "doesn't raise if upper bound is exclusive" do
        m.slice({0,3}, {0,3}).should eq(m)
      end
    end
  end

  context "reshape" do
      m = Ndarray.new([1,2,3,4])
      it "reshape an array using C-like index order" do
        reshaped_array = Ndarray[[1,2],[3,4]]
        m.reshape(2,2, "C").should eq(reshaped_array)
      end

      it "reshape an array using Fortran-like index order" do
        reshaped_array = Ndarray[[1,3],[2,4]]
        m.reshape(2,2, "F").should eq(reshaped_array)
      end
  end


  context "/" do
    it "divide two matrices" do
      m1 = Ndarray.new [
        [1, 2],
        [3, 4],
        [5, 6],
      ]
      m2 = Ndarray.new [
        [7, 8],
        [9, 10],
        [11, 12],
      ]
      expected = Ndarray.new [
        [7.0/1.0, 8.0/2.0],
        [9.0/3.0, 10.0/4.0],
        [11.0/5.0, 12.0/6.0],
      ]
      (m2 / m1).should eq(expected)
    end

    it "raises if rows don't match" do
      m1 = Ndarray.new [
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7, 8],
        [8, 9],
      ]
      expect_raises ArgumentError do
        m1 / m2
      end
    end

    it "raises if cols don't match" do
      m1 = Ndarray.new [
        [1, 2],
        [1, 2],
      ]
      m2 = Ndarray.new [
        [7, 8, 10],
        [8, 9, 10],
      ]
      expect_raises ArgumentError do
        m1 / m2
      end
    end
  end

  context "*" do
      it "multiple two matrices elements" do
        m1 = Ndarray.new [
          [1, 2],
          [3, 4],
          [5, 6],
        ]
        m2 = Ndarray.new [
          [7, 8],
          [9, 10],
          [11, 12],
        ]
        expected = Ndarray.new [
          [7.0*1.0, 8.0*2.0],
          [9.0*3.0, 10.0*4.0],
          [11.0*5.0, 12.0*6.0],
        ]
        (m2 * m1).should eq(expected)

        m3 = Ndarray.new([1,2,3])
        m4 = Ndarray.new([4,5,6])

        (m3 * m4).should eq(Ndarray.new([4.0,10.0,18.0]))
      end

      it "raises if rows don't match" do
        m1 = Ndarray.new [
          [1, 2],
        ]
        m2 = Ndarray.new [
          [7, 8],
          [8, 9],
        ]
        expect_raises ArgumentError do
          m1 * m2
        end
      end

      it "raises if cols don't match" do
        m1 = Ndarray.new [
          [1, 2],
          [1, 2],
        ]
        m2 = Ndarray.new [
          [7, 8, 10],
          [8, 9, 10],
        ]
        expect_raises ArgumentError do
          m1 * m2
        end
      end
  end

  context "sqrt" do
      it "square root of an array" do
        m1 = Ndarray.new [
          [1, 2],
          [3, 4],
          [5, 6],
        ]
        m2 = Ndarray.new [7, 8, 9, 10]

        expected_m2 = Ndarray.new ([Math.sqrt(7.0), Math.sqrt(8.0), Math.sqrt(9.0), Math.sqrt(10.0)])

        expected_m1 = Ndarray.new [
          [Math.sqrt(1.0), Math.sqrt(2.0)],
          [Math.sqrt(3.0), Math.sqrt(4.0)],
          [Math.sqrt(5.0), Math.sqrt(6.0)],
        ]

        (m1.sqrt).should eq(expected_m1)
        (m2.sqrt).should eq(expected_m2)
      end
  end


  context "sum" do
      m = Ndarray[[1,2],[3,4]]

      it "sum all elements of an array" do
        m.sum.should eq 10
      end

      it "column wise sum" do
        m.sum(0).should eq([4,6])
      end

      it "row wise sum" do
        m.sum(1).should eq([3,7])
      end
  end


  context ">" do
      m1 = Ndarray[[1,2], [3, 4], [5, 6]]

      it "Boolean array indexing" do
        (m1 > 3).should eq Ndarray.new([[0,0],[0,1],[1,1]])
      end

      m2 = Ndarray.new([1,2,3,4,5,6])

      it "Boolean array indexing" do
        (m2 > 3).should eq Ndarray.new([0,0,0,1,1,1])
      end
  end

  context "<" do
      m = Ndarray[[1,2], [3, 4], [5, 6]]

      it "Boolean array indexing" do
        (m < 3).should eq Ndarray.new([[1,1],[0,0],[0,0]])
      end
  end

  context "==" do
      m = Ndarray[[1,2], [3, 4], [5, 6]]

      it "Boolean array indexing" do
        (m == 3).should eq Ndarray.new([[0,0],[1,0],[0,0]])
      end
  end

  context "broadcasting" do
      m1 = Ndarray.new([1.0,2.0,3.0])
      m2 = Ndarray.new([[ 0.0, 0.0, 0.0],
                        [10.0,10.0,10.0],
                        [20.0,20.0,20.0],
                        [30.0,30.0,30.0]])
      m3 = Ndarray.new([[1.0],[2.0],[3.0],[4.0]])
      m4 = Ndarray.new([[0.0],[10.0],[20.0],[30.0]])
      it "broadcasting for *" do
        (m1*2).should eq(Ndarray.new([2.0, 4.0, 6.0]))
      end

      it "broadcasting for +" do
        (m2 + m1).should eq(Ndarray.new([[  1.0,   2.0,   3.0],
                                         [ 11.0,  12.0,  13.0],
                                         [ 21.0,  22.0,  23.0],
                                         [ 31.0,  32.0,  33.0]]))

        (m2 + m3).should eq(Ndarray.new([[  1.0,   1.0,   1.0],
                                         [ 12.0,  12.0,  12.0],
                                         [ 23.0,  23.0,  23.0],
                                         [ 34.0,  34.0,  34.0]]))

        (m3 + m1).should eq(Ndarray.new([[  2.0,   3.0,   4.0],
                                         [  3.0,   4.0,   5.0],
                                         [  4.0,   5.0,   6.0],
                                         [  5.0,   6.0,   7.0]]))

      end
  end
end






