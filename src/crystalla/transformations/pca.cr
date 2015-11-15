module Crystalla
  class Matrix
    # Uses this matrix as a n_samples * n_features model to fit a PCA transformation with the specified number of components
    def pca_fit(n_components : Int32) : Transformations::PCA
      Transformations::PCA.new(self, n_components)
    end

    # Uses this matrix as a n_samples * n_features model to fit a PCA transformation and reduces it to the specified number of components
    def pca_transform(n_components : Int32) : Crystalla::Matrix
      Transformations::PCA.new(self, n_components).transform
    end
  end

  module Transformations
    class PCA
      getter :n_components

      # Initializes a new PCA object with the model to fit and the number of components to use
      # The model should be a n_samples * n_features matrix
      def initialize(x : Crystalla::Matrix, @n_components : Int32)
        raise ArgumentError.new("Number of components must be smaller or equal to min(n_samples, n_features)") if @n_components > x.number_of_rows || @n_components > x.number_of_cols
        x_centered = center(x)
        @u, @s, @vt = x_centered.svd
      end

      # Reduces the original model to the specified number of components
      def transform : Crystalla::Matrix
        u_components * Crystalla::Matrix.diag(s_values)
      end

      # Reduces the input matrix based on the dimensions obtained from the original model
      def transform(y : Crystalla::Matrix) : Crystalla::Matrix
        center(y) * vt_components.transpose
      end

      private def center(x : Crystalla::Matrix) : Crystalla::Matrix
        mean_sample = x.mean_by_col
        return x - Crystalla::Matrix.repeat_row(mean_sample, x.number_of_rows)
      end

      private def s_values
        @s_values ||= @s[0...n_components]
      end

      private def u_components
        @u_components ||= @u[0..-1, 0...@n_components]
      end

      private def vt_components
        @vt_components ||= @vt[0...@n_components, 0..-1]
      end
    end
  end
end
