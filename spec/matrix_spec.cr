require "./spec_helper"

describe Crystalla::Matrix do
  it "creates a Matrix from given columns" do
    m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]

    m[0, 0].should eq(1)
    m[0, 1].should eq(2)
    m[1, 0].should eq(3)
    m[1, 1].should eq(4)
  end

  context "dimensions" do
    it "with same number of cols and rows" do
      m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m.dimensions.should eq({2,2})
    end

    it "with different number of cols and rows" do
      m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0], [1.0, 3.0], [2.0, 4.0]]
      m.dimensions.should eq({2,4})
    end
  end

  context "comparison" do
    it "with similar matrixes" do
      m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m2 = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m.all_close(m2).should be_true
    end

    it "with matrixes with different dimensions" do
      m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m2 = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0], [3.0, 5.0]]
      m.all_close(m2).should be_false
    end

    it "with matrixes with same dimensions and different values" do
      m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
      m2 = Crystalla::Matrix.columns [[1.0, 5.0], [2.0, 4.0]]
      m.all_close(m2).should be_false
    end
  end

  it "inverts a Matrix" do
    m = Crystalla::Matrix.columns [[1.0, 3.0], [2.0, 4.0]]
    inverse = Crystalla::Matrix.columns [[-2.0, 1.5], [1.0, -0.5]]

    m.invert!.all_close(inverse).should be_true
  end
end
