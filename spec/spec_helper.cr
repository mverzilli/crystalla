require "spec"
require "../src/crystalla"
require "../src/crystalla/spec/*"

include Crystalla
include Crystalla::Spec::Expectations

Crystalla.display_info!
