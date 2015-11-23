HOST=http://yann.lecun.com/exdb/mnist/

all: download

download: data data/train-labels data/train-images data/test-labels data/test-images

data:
	mkdir -p data

data/train-labels:
	curl $(HOST)train-labels-idx1-ubyte.gz | gunzip > $@

data/train-images:
	curl $(HOST)train-images-idx3-ubyte.gz | gunzip > $@

data/test-labels:
	curl $(HOST)t10k-labels-idx1-ubyte.gz | gunzip > $@

data/test-images:
	curl $(HOST)t10k-images-idx3-ubyte.gz | gunzip > $@
