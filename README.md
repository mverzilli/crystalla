# Crystalla

![Build status](https://circleci.com/gh/mverzilli/crystalla.svg?style=shield&circle-token=:circle-token)

Crystalla is a Numerical Methods library for the Crystal programming language. It binds to LAPACK and looks to Numpy for API and design ideas.

Works on OSX and Ubuntu, using the Accelerate framework and liblapack+libblas respectively.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystalla:
    github: mverzilli/crystalla
```

On Ubuntu, you may need to install the following packages:
```
liblapack-dev liblapack-doc-man liblapack-doc liblapack-pic liblapack3 liblapack-test liblapack3gf liblapacke liblapacke-dev libblas-dev libblas-doc liblapacke-dev liblapack-doc
```

## Usage

```crystal
require "crystalla"

# Matrixes are created from column arrays
m = Crystalla::Matrix.columns [[1.0, 2.0], [3.0, 4.0]]

puts "This is how M looks now: "
puts m
puts

puts "This is M's inverse (note it's inverted in place): "
m.invert!
puts m
```

Output:

```text
This is how M looks now:
Matrix[[ 1, 3 ],
       [ 2, 4 ]]

This is M's inverse (note it's inverted in place):
Matrix[[ -2,  1.5 ],
       [  1, -0.5 ]]
 ```

## Features implemented so far

* Load matrices from space separated plain text files.
* Create constant matrices.
* Add rows at an arbitrary position (non-destructive).
* Compare two matrices value-by-value: exact match or closeness (given absolute and relative epsilon values).
* Invert matrices (destructive).
* Solve linear equations systems.
* Singular Value Decomposition.

## Development

Development on OSX works out of the box. To try the library on Ubuntu from OSX, you can use the associated docker image, and run it mounting crystalla. First, build the image:
```
docker build -t mverzilli/crystalla .
```

And fire up a new container by running:
```
docker run --rm -it -v `pwd`:/opt/crystalla mverzilli/crystalla
```

You can run `crystal spec` to check everything is working fine.

## Contributing

1. Fork it ( https://github.com/mverzilli/crystalla/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- @mverzilli(https://github.com/mverzilli) Martin Verzilli - creator, maintainer
