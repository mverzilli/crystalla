require "../spec_helper"

describe Crystalla::Transformations::PCA do
  # Expected values were generated from scipy with the following code:
  #
  # ```python
  # import numpy as np
  # from sklearn.decomposition import PCA

  # X = np.array([[1.0, 0.8, 1.4], [1.2, 0.5, 1.9], [0.8, 1.3, 0.3], [0.4, 1.3, 0.9], [1.5, 0.4, 0.3]])
  # pca = PCA(n_components=2)
  # X_transf = pca.fit_transform(X)
  # print X_transf
  # ```

  it "should fit and transform a matrix" do
    m = Matrix.rows([[1.0, 0.8, 1.4], [1.2, 0.5, 1.9], [0.8, 1.3, 0.3], [0.4, 1.3, 0.9], [1.5, 0.4, 0.3]])
    expected = Matrix.rows([[-0.43046507, 0.10721575],
      [-1.02945786, -0.0381158],
      [0.7909312, 0.16027353],
      [0.30650982, 0.65581936],
      [0.36248191, -0.88519284]])

    m.pca_transform(2).should be_all_close(expected)
  end

  it "should fit then transform a matrix" do
    m = Matrix.rows([[1.0, 0.8, 1.4], [1.2, 0.5, 1.9], [0.8, 1.3, 0.3], [0.4, 1.3, 0.9], [1.5, 0.4, 0.3]])
    expected = Matrix.rows([[-0.43046507, 0.10721575],
      [-1.02945786, -0.0381158],
      [0.7909312, 0.16027353],
      [0.30650982, 0.65581936],
      [0.36248191, -0.88519284]])

    pca = m.pca_fit(2)
    pca.transform(m).should be_all_close(expected)
  end
end
