# Crystalla

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

p "This is how M looks now: "
m.print

p "This is M's inverse (note it's inverted in place): "
m.invert!
m.print

# => "This is how M looks now: "
# => "| 1  3 |"
# => "| 2  4 |"
# => "This is M's inverse (note it's inverted in place): "
# => "| -2  1.5 |"
# => "| 1  -0.5 |"
```

## Development

Currently it only supports development and usage on OS X. 

## Contributing

1. Fork it ( https://github.com/mverzilli/crystalla/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- @mverzilli(https://github.com/mverzilli) Martin Verzilli - creator, maintainer
