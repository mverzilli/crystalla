require "http"
require "../../src/crystalla"

include Crystalla

PCA_N_COMPONENTS = 40

TRAIN_IMAGES_PATH = "data/train-images"
TRAIN_LABELS_PATH = "data/train-labels"
TEST_IMAGES_PATH  = "data/test-images"
TEST_LABELS_PATH  = "data/test-labels"

TRAINING_SIZE = 6000 # up to 60000
TESTING_SIZE  = 1000 # up to 10000


def read_labels(path, count)
  File.open(path, "rb") do |file|
    magic = file.read_bytes(Int32, IO::ByteFormat::BigEndian)
    raise "Invalid magic value: read #{magic}, expected 2049" unless magic == 2049

    nitems = file.read_bytes(Int32, IO::ByteFormat::BigEndian)
    nitems = [nitems, count].min

    labels = Array(UInt8).new(nitems)
    nitems.times do
      labels << file.read_byte.not_nil!
    end

    return labels
  end
end

def read_images(path, count)
  File.open(path, "rb") do |file|
    magic = file.read_bytes(Int32, IO::ByteFormat::BigEndian)
    raise "Invalid magic value: read #{magic}, expected 2051" unless magic == 2051

    nimgs = file.read_bytes(Int32, IO::ByteFormat::BigEndian)
    nrows = file.read_bytes(Int32, IO::ByteFormat::BigEndian)
    ncols = file.read_bytes(Int32, IO::ByteFormat::BigEndian)

    nimgs = [nimgs, count].min

    imgs = Array(Array(UInt8)).new(nimgs)
    nimgs.times do
      imgs << (img = Array(UInt8).new(nrows * ncols))
      (nrows * ncols).times do
        img << file.read_byte.not_nil!
      end
    end

    return {imgs, nrows, ncols}
  end
end

def load(img_path, label_path, count)
  imgs, nrows, ncols = read_images(img_path, count)
  labels = read_labels(label_path, count)
  {Matrix.rows(imgs), labels}
end

def distance(array_1, array_2)
  raise "Array dimensions do not match" if array_1.size != array_2.size
  value = 0.0
  array_1.size.times do |i|
    value += (array_1[i] - array_2[i]) ** 2
  end
  return value
end

# Load train data
images, labels = load(TRAIN_IMAGES_PATH, TRAIN_LABELS_PATH, TRAINING_SIZE)
puts "Loaded #{labels.size} images for training"

# Normalise by number of images
div = Math.sqrt(images.number_of_rows - 1)
images.each_by_col do |value, i, j|
  images[i, j] = value / div
end
puts "Normalised training set"

# Run PCA on the training set
pca = images.pca_fit(PCA_N_COMPONENTS)
puts "PCA fit with #{PCA_N_COMPONENTS} on the training set"
reduced_train_images = pca.transform
puts "Transformed the training set using the PCA fit"

# Load test data and apply same normalisation as training set
test_images, test_labels = load(TEST_IMAGES_PATH, TEST_LABELS_PATH, TESTING_SIZE)
puts "\nLoaded #{labels.size} images for testing"
test_images.each_by_col do |value, i, j|
  test_images[i, j] = value / div
end
puts "Normalised testing set"

# Apply PCA trained transformation on test data
reduced_test_images = pca.transform(test_images)
puts "Transformed the testing set using the PCA fit"

# Guess each label based on the closest point from the training set
guessed_labels = Array(UInt8).new(test_labels.size)
reduced_test_images.each_row do |test_image, i_test|
  best_distance = Float64::INFINITY
  best_guess = UInt8.new(0)
  reduced_train_images.each_row do |train_image, i_train|
    current_distance = distance(test_image, train_image)
    if current_distance < best_distance
      best_distance = current_distance
      best_guess = labels[i_train]
    end
  end
  guessed_labels << best_guess
end

# Compute percentage of correct guesses
n_correct = test_labels.zip(guessed_labels).count { |x| x[0] == x[1] }
puts "\nCorrect answers: #{n_correct} / #{test_labels.size} (#{n_correct.to_f / test_labels.size.to_f})"
