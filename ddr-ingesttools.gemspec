# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ddr/ingesttools/version'

Gem::Specification.new do |spec|
  spec.name          = "ddr-ingesttools"
  spec.version       = Ddr::IngestTools::VERSION
  spec.authors       = ["Jim Coble"]
  spec.email         = ["jim.coble@duke.edu"]
  spec.summary       = "Ruby tools supporting ingest into the Duke Digital Repository."
  spec.description   = "A collection of Ruby tools supporting ingest into the Duke Digital Repository."
  spec.homepage      = "https://github.com/duke-libraries/ddr-ingesttools"
  spec.license       = "BSD-3-Clause"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bagit", "~> 0.4"
  spec.add_dependency "i18n", "~> 0.8"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
