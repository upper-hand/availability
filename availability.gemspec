# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'availability/version'

Gem::Specification.new do |spec|
  spec.name                  = "availability"
  spec.version               = Availability::VERSION
  spec.authors               = ["Jason Rogers"]
  spec.email                 = ["jacaetevha@gmail.com"]

  spec.summary               = %q{Calculating schedule availability}
  spec.description           = %q{Use modular arithmetic and residue classes to calculate schedule availability for dates and times.}
  spec.homepage              = "https://github.com/upper-hand/availability"
  spec.license               = "Unlicense"
  spec.required_ruby_version = '>= 2.0'

  spec.files                 = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir                = "exe"
  spec.executables           = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths         = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
