module Crystalla
  class Samples
    def self.make_blobs(n_samples=100, n_features=2, centers=3, cluster_std=1.0, center_box={-10.0, 10.0}, shuffle=true, random_state=nil)
      # Generate isotropic Gaussian blobs for clustering.

      # Parameters
      # ----------
      # n_samples : int, optional (default=100)
      #     The total number of points equally divided among clusters.

      # n_features : int, optional (default=2)
      #     The number of features for each sample.

      # centers : int or array of shape [n_centers, n_features], optional
      #     (default=3)
      #     The number of centers to generate, or the fixed center locations.

      # cluster_std : float or sequence of floats, optional (default=1.0)
      #     The standard deviation of the clusters.

      # center_box : pair of floats (min, max), optional (default=(-10.0, 10.0))
      #     The bounding box for each cluster center when centers are
      #     generated at random.

      # shuffle : boolean, optional (default=True)
      #     Shuffle the samples.

      # random_state : int, RandomState instance or None, optional (default=None)
      #     If int, random_state is the seed used by the random number generator;
      #     If RandomState instance, random_state is the random number generator;
      #     If None, the random number generator is the RandomState instance used
      #     by `np.random`.

      # Returns
      # -------
      # X : array of shape [n_samples, n_features]
      #     The generated samples.

      # y : array of shape [n_samples]
      #     The integer labels for cluster membership of each sample.
      #

      generator = Random.new_seed
      values = [] of Array(Float64)
      (0...centers).each do |i|
        generated_numbers = [] of Float64
        (0...n_features).each do |j|
          generated_numbers << Random.new.rand(center_box[0]..center_box[1])
        end
        values << generated_numbers
      end
      centers = Crystalla::Ndarray.new(values)
      x = [] of Crystalla::Ndarray
      y = Crystalla::Ndarray.new([] of Float64)

      n_centers = centers.shape[0]
      n_samples_per_center = Array.new(n_centers, (n_samples / n_centers).to_i)

      (0...n_samples % n_centers).each do |i|
        n_samples_per_center[i] +=1
      end

      zipped = [] of Tuple(Float64, Float64)
      cluster = Array.new(n_samples_per_center.size, cluster_std)
      n_samples_per_center.each_with_index do |el, index|
        zipped << {el.to_f, cluster[index].to_f}
      end

      values = [] of Float64
      (0...zipped.size).each do |el|
        x << (Crystalla::RandomGaussian.new.rand_array(zipped[el][0].to_i, n_features) + Ndarray.new(centers[el], {1,3}))
        values += Array.new(zipped[el][0].to_i, el.to_f64)
      end
      y = Crystalla::Ndarray.new(values)

      x_ = x.first
      (1...x.size).each do |i|
        x_ = x_.concatenate(x[i])
      end

      return x_, y
    end
  end
end
