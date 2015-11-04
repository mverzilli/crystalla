# Crystalla

[![Build Status](https://travis-ci.org/mverzilli/crystalla.svg?branch=master)](https://travis-ci.org/mverzilli/crystalla)

Crystalla is a Numerical Methods library for the Crystal programming language. It binds to LAPACK and looks to Numpy for API and design ideas.

It currently only works on OS X.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crystalla:
    github: mverzilli/crystalla
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

Currently it only supports development and usage on OS X, but it should be almost trivial to support Linux distros.

## Contributing

1. Fork it ( https://github.com/mverzilli/crystalla/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- @mverzilli(https://github.com/mverzilli) Martin Verzilli - creator, maintainer
