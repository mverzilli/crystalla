require "./spec_helper"
require "benchmark"

describe Matrix do
  context "creation" do
    it "creates a Matrix from given columns" do
      m = Matrix.columns [[1, 3], [2, 4]]

      m[0, 0].should eq(1)
      m[0, 1].should eq(2)
      m[1, 0].should eq(3)
      m[1, 1].should eq(4)
    end

    it "raises on dimension mismatch with columns" do
      expect_raises ArgumentError, "column #2 must have 2 rows, not 3" do
        Matrix.columns [[1, 3], [2, 4, 5]]
      end
    end

    it "creates a Matrix from given rows" do
      m = Matrix.rows [
            [1, 2],
            [3, 4],
          ]

      m[0, 0].should eq(1)
      m[0, 1].should eq(2)
      m[1, 0].should eq(3)
      m[1, 1].should eq(4)
    end

    it "raises on dimension mismatch with rows" do
      expect_raises ArgumentError, "row #2 must have 2 columns, not 3" do
        Matrix.rows [[1, 3], [2, 4, 5]]
      end
    end

    it "creates a matrix of zeros" do
      m = Matrix.zeros(1, 2)
      m.dimensions.should eq({1, 2})
      m[0, 0].should eq(0)
      m[0, 1].should eq(0)
    end

    it "creates a matrix of ones" do
      m = Matrix.ones(1, 2)
      m.dimensions.should eq({1, 2})
      m[0, 0].should eq(1)
      m[0, 1].should eq(1)
    end

    it "creates a square identity matrix" do
      m = Matrix.eye(2)
      m.dimensions.should eq({2, 2})
      m.should eq(Matrix.rows([[1.0, 0.0], [0.0, 1.0]]))
    end

    it "creates an identity matrix with more rows" do
      m = Matrix.eye(3, 2)
      m.dimensions.should eq({3, 2})
      m.should eq(Matrix.rows([[1.0, 0.0], [0.0, 1.0], [0.0, 0.0]]))
    end

    it "creates an identity matrix with more cols" do
      m = Matrix.eye(2, 3)
      m.dimensions.should eq({2, 3})
      m.should eq(Matrix.rows([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]]))
    end

    it "creates a row vector given an array" do
      m = Matrix.row_vector [3,2,1]
      m.dimensions.should eq({1,3})
      [3,2,1].each_with_index {|val, index| val.should eq m[0,index]}
    end

    it "creates a row vector containing a random permutation of the integers from 0 to n exclusive" do
      m = Matrix.rand_perm(3)
      m.dimensions.should eq ({1, 3})
      [0,1,2].permutations(3).map{|p| Matrix.row_vector(p)}.any?(&.==(m)).should be_true
    end

    it "raises if zeros gets negative rows or cols" do
      expect_raises ArgumentError, "negative number of rows" do
        Matrix.zeros(-1, 2)
      end

      expect_raises ArgumentError, "negative number of columns" do
        Matrix.zeros(1, -1)
      end
    end

    it "loads from space separated file" do
      m = Matrix.load "spec/housing.data"

      m.number_of_rows.should eq(506)
      m.number_of_cols.should eq(14)

      m[0, 0].should eq(0.00632)
      m[6, 0].should eq(0.08829)
      m[15, 0].should eq(0.62739)
      m[0, 1].should eq(18.0)
      m[99, 2].should eq(2.890)
      m[112, 11].should eq(394.95)
    end

    it "creates a random matrix" do
      m = Matrix.rand(2, 3)
      m.dimensions.should eq({2, 3})
      m.values.each do |value|
        (0.0 <= value <= 1.0).should be_true
      end
    end

    it "creates a random matrix with integer values" do
      m = Matrix.rand(2, 3, (10..20))
      m.dimensions.should eq({2, 3})
      m.values.each do |value|
        (10 <= value <= 20).should be_true
        (value - value.to_i).should be_close(0, 0.0000001)
      end
    end

    it "creates a square diagonal matrix from an array" do
      m = Matrix.diag([1.0, 2.0])
      expected = Matrix.rows([[1.0, 0.0], [0.0, 2.0]])
      m.should be_all_close(expected)
    end

    it "creates a 2x3 diagonal matrix from an 2-elems array" do
      m = Matrix.diag([1.0, 2.0], 2, 3)
      expected = Matrix.rows([[1.0, 0.0, 0.0], [0.0, 2.0, 0.0]])
      m.should be_all_close(expected)
    end

    it "creates a 3x2 diagonal matrix from an 2-elems array" do
      m = Matrix.diag([1.0, 2.0], 3, 2)
      expected = Matrix.rows([[1.0, 0.0], [0.0, 2.0], [0.0, 0.0]])
      m.should be_all_close(expected)
    end

    it "creates a 3x2 diagonal matrix from an 4-elems array" do
      m = Matrix.diag([1.0, 2.0, 3.0, 4.0], 3, 2)
      expected = Matrix.rows([[1.0, 0.0], [0.0, 2.0], [0.0, 0.0]])
      m.should be_all_close(expected)
    end

    it "creates with #[]" do
      m = Matrix[
        [1, 2],
        [3, 4],
      ]

      m[0, 0].should eq(1)
      m[0, 1].should eq(2)
      m[1, 0].should eq(3)
      m[1, 1].should eq(4)
    end
  end

  context "dimensions" do
    it "with same number of cols and rows" do
      m = Matrix.columns [[1, 3], [2, 4]]
      m.dimensions.should eq({2, 2})
    end

    it "with different number of cols and rows" do
      m = Matrix.columns [[1, 3], [2, 4], [1, 3], [2, 4]]
      m.dimensions.should eq({2, 4})
    end
  end

  context "comparison" do
    it "checks two matrices are equal" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m2 = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]

      m.should eq(m2)
    end

    it "checks two matrices are not equal" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m2 = Matrix.columns [[3.0, 3.0], [2.0, 4.0]]

      m.should_not eq(m2)
    end

    it "with similar matrices" do
      m = Matrix.columns [[1, 3], [2, 4]]
      m2 = Matrix.columns [[1, 3], [2, 4]]
      m.all_close(m2).should be_true
    end

    it "with matrices with different dimensions" do
      m = Matrix.columns [[1, 3], [2, 4]]
      m2 = Matrix.columns [[1, 3], [2, 4], [3, 5]]
      m.all_close(m2).should be_false
    end

    it "with matrices with same dimensions and different values" do
      m = Matrix.columns [[1, 3], [2, 4]]
      m2 = Matrix.columns [[1, 5], [2, 4]]
      m.all_close(m2).should be_false
    end
  end

  context "invert" do
    it "inverts a Matrix" do
      m = Matrix.columns [[1, 3], [2, 4]]
      inverse = Matrix.columns [[-2, 1.5], [1, -0.5]]

      m.invert!.should be_all_close(inverse)
    end

    it "raises if non-square" do
      m = Matrix.columns [[1, 3], [2, 4], [5, 6]]
      expect_raises ArgumentError, "can't invert non-square matrix" do
        m.invert!
      end
    end
  end

  context "*" do
    it "mutliplies two matrices" do
      m1 = Matrix.rows [
             [1, 2],
             [3, 4],
             [5, 6],
           ]
      m2 = Matrix.rows [
             [7, 8, 9],
             [10, 11, 12],
           ]
      expected = Matrix.rows [
                   [1 * 7 + 2 * 10, 1 * 8 + 2 * 11, 1 * 9 + 2 * 12],
                   [3 * 7 + 4 * 10, 3 * 8 + 4 * 11, 3 * 9 + 4 * 12],
                   [5 * 7 + 6 * 10, 5 * 8 + 6 * 11, 5 * 9 + 6 * 12],
                 ]
      (m1 * m2).should be_all_close(expected)
    end

    it "raises if rows don't match columns" do
      m1 = Matrix.rows [
             [1, 2],
           ]
      m2 = Matrix.rows [
             [7],
             [8],
             [9],
           ]
      expect_raises ArgumentError, "number of rows/columns mismatch in matrix multiplication" do
        m1 * m2
      end
    end
  end

  context "+" do
    it "adds two matrices" do
      m1 = Matrix.rows [
             [1, 2],
             [3, 4],
             [5, 6],
           ]
      m2 = Matrix.rows [
             [7, 8],
             [9, 10],
             [11, 12],
           ]
      expected = Matrix.rows [
                   [8, 10],
                   [12, 14],
                   [16, 18],
                 ]
      (m1 + m2).all_close(expected).should be_true
    end

    it "raises if rows don't match" do
      m1 = Matrix.rows [
             [1, 2],
           ]
      m2 = Matrix.rows [
             [7, 8],
             [8, 9],
           ]
      expect_raises ArgumentError do
        m1 + m2
      end
    end

    it "raises if cols don't match" do
      m1 = Matrix.rows [
             [1, 2],
             [1, 2],
           ]
      m2 = Matrix.rows [
             [7, 8, 10],
             [8, 9, 10],
           ]
      expect_raises ArgumentError do
        m1 + m2
      end
    end
  end

  context "unary -" do
    it "negates a matrix" do
      m = Matrix.rows([[1.0, 2.0], [-3.0, -4.0]])
      expected = Matrix.rows([[-1.0, -2.0], [3.0, 4.0]])
      (-m).should be_all_close(expected)
      m.should be_all_close(Matrix.rows([[1.0, 2.0], [-3.0, -4.0]]))
    end
  end

  context "add rows" do
    it "adds a row at the beginning" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      new_row = [1.0] * m.number_of_cols

      new_m = m.prepend(new_row)

      new_m.should eq(Matrix.columns [[1.0, 1.0, 3.0], [1.0, 2.0, 4.0]])
    end

    it "adds a row at the middle" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      new_row = [1.0] * m.number_of_cols

      new_m = m.add_row(1, new_row)

      new_m.should eq(Matrix.columns [[1.0, 1.0, 3.0], [2.0, 1.0, 4.0]])
    end

    it "adds a Matrix that's a row vector at the middle" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      new_row = Matrix.ones(1, m.number_of_cols)

      new_m = m.add_row(1, new_row)
      new_m.should eq(Matrix.columns [[1.0, 1.0, 3.0], [2.0, 1.0, 4.0]])
    end

    it "adds a row at the bottom" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      new_row = [1.0] * m.number_of_cols

      new_m = m.append(new_row)

      new_m.should eq(Matrix.columns [[1.0, 3.0, 1.0], [2.0, 4.0, 1.0]])
    end
  end

  context "clone" do
    it "clones a matrix" do
      m = Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m2 = m.clone
      m[0, 0] = 1.1

      m[0, 0].should eq(1.1)
      m2[0, 0].should eq(1.0)
    end
  end

  context "solve" do
    it "solves a square system for a single rhs" do
      m = Matrix.rows [[2.0, 1.0, 3.0], [2.0, 6.0, 8.0], [6.0, 8.0, 18.0]]
      b = Matrix.columns [[1.0, 3.0, 5.0]]
      x = m.solve(b)
      expected = Matrix.columns [[0.3, 0.4, 0.0]]
      x.should be_all_close(expected)
    end

    it "solves a square system for multiple rhss" do
      m = Matrix.rows [[2.0, 1.0, 3.0], [2.0, 6.0, 8.0], [6.0, 8.0, 18.0]]
      b = Matrix.columns [[1.0, 3.0, 5.0], [2.0, 6.0, 10.0]]
      x = m.solve(b)
      expected = Matrix.columns [[0.3, 0.4, 0.0], [0.6, 0.8, 0.0]]
      x.should be_all_close(expected)
    end
  end

  context "transpose" do
    it "transposes" do
      m = Matrix.rows [[1, 2, 3], [3, 2, 1]]
      m.transpose.should eq(Matrix.columns [[1, 2, 3], [3, 2, 1]])
    end
  end

  context "svd" do
    it "returns full SVD" do
      a = Matrix.rows([[3.0, 2.0, 2.0], [2.0, 3.0, -2.0]])
      u, s, vt = a.svd

      u.should be_all_close(Matrix.rows([[-0.7071, -0.7071], [-0.7071, 0.7071]]))
      vt.should be_all_close(Matrix.rows([[-0.7071, -0.7071, 0.0], [-0.2357, 0.2357, -0.9428], [-0.6667, 0.6667, 0.3333]]), 0.001, 0.0)
      s.should be_all_close([5.0, 3.0])

      (u * Matrix.diag(s, a.number_of_rows, a.number_of_cols) * vt).should be_all_close(a)
    end

    it "returns singular values only" do
      a = Matrix.rows([[3.0, 2.0, 2.0], [2.0, 3.0, -2.0]])
      s = a.singular_values
      s.should be_all_close([5.0, 3.0])
    end
  end

  context "to_s" do
    it "with integers" do
      Matrix[
        [1, 2],
        [3, 4],
      ].to_s.should eq(
        <<-STR
Matrix[[ 1, 2 ],
       [ 3, 4 ]]
STR
      )
    end

    it "with integers of different sizes" do
      Matrix[
        [10, 2],
        [3, 40],
      ].to_s.should eq(
        <<-STR
Matrix[[ 10,  2 ],
       [  3, 40 ]]
STR
      )
    end

    it "with floats of different sizes" do
      Matrix[
        [10.1, 2.123],
        [3.45, 40.1],
      ].to_s.should eq(
        <<-STR
Matrix[[ 10.1 ,  2.123 ],
       [  3.45, 40.1   ]]
STR
      )
    end

    it "with int and floats" do
      Matrix[
        [1, 2],
        [0.1, 0.2],
      ].to_s.should eq(
        <<-STR
Matrix[[ 1  , 2   ],
       [ 0.1, 0.2 ]]
STR
      )
    end
  end

  context "observers (as in Algebraic Data Types, not the pattern!)" do
    it "row_vector?" do
      m1 = Matrix.rows [[1,1],[2,2]]
      m2 = Matrix.rows [[1,1,2,2]]
      m1.row_vector?.should be_false
      m2.row_vector?.should be_true
    end
  end
end
