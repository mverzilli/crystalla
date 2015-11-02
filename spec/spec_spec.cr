require "./spec_helper"

describe Crystalla::Spec::Expectations do
  context "matrices" do
    it "should pass all close" do
      a = Matrix.columns [[1.0, 2.0], [3.0, 4.0]]
      b = Matrix.columns [[1.0, 2.0], [3.0, 4.00000001]]

      a.should be_all_close(b)
    end

    it "should fail all close when dimensions are different" do
      a = Matrix.columns [[1.0, 2.0]]
      b = Matrix.columns [[1.0, 2.0], [3.0, 5.0]]

      a.should_not be_all_close(b)
    end

    it "should fail all close when values are different" do
      a = Matrix.columns [[1.0, 2.0], [3.0, 4.0]]
      b = Matrix.columns [[1.0, 2.0], [3.0, 5.0]]

      a.should_not be_all_close(b)
    end
  end

  context "tolerance" do
    it "should fail with default tolerance" do
      a = Matrix.columns([[2.0]])
      b = Matrix.columns([[2.09]])
      a.should_not be_all_close(b)
    end

    it "should pass with high absolute tolerance" do
      a = Matrix.columns([[2.0]])
      b = Matrix.columns([[2.09]])
      a.should be_all_close(b, 0.1, 0.0)
    end

    it "should pass with high relative tolerance" do
      a = Matrix.columns([[2.0]])
      b = Matrix.columns([[2.09]])
      a.should be_all_close(b, 0.0, 0.05)
    end
  end

  context "arrays" do
    it "should pass all close" do
      a = [1.0, 2.0]
      a.should be_all_close([1.00000001, 1.999999])
    end

    it "should fail all close with different dimensions" do
      a = [1.0, 2.0]
      a.should_not be_all_close([1.0, 2.0, 3.0])
    end

    it "should fail all close with different values" do
      a = [1.0, 2.0]
      a.should_not be_all_close([1.0, 2.1])
    end
  end
end
