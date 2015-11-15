require "./spec_helper"

describe Matrix do
  context "stats" do
    it "should calculate the mean value of the matrix" do
      m = Matrix.columns [[1.0, 3.0, 5.0], [2.0, 4.0, 6.0]]
      m.mean.should eq(3.5)
    end

    it "should calculate the mean value of the matrix by rows" do
      m = Matrix.columns [[1.0, 3.0, 5.0], [2.0, 4.0, 6.0]]
      m.mean_by_row.should eq([1.5, 3.5, 5.5])
    end

    it "should calculate the mean value of the matrix by columns" do
      m = Matrix.columns [[1.0, 3.0, 5.0], [2.0, 4.0, 6.0]]
      m.mean_by_col.should eq([3.0, 4.0])
    end
  end
end
