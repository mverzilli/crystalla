require "./spec_helper"

describe Crystalla::Spec::Expectations do
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
