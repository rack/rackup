# frozen_string_literal: true

require_relative "lib/rackup/version"

Gem::Specification.new do |spec|
  spec.name = "rackup"
  spec.version = Rackup::VERSION

  spec.summary = "A general server command for Rack applications."
  spec.authors = ["Samuel Williams", "Jeremy Evans"]
  spec.license = "MIT"

  spec.homepage = "https://github.com/rack/rackup"

  spec.files = Dir['{bin,lib}/**/*', '*.md']

  spec.executables = ["rackup"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_dependency "rack", ">= 3"
  spec.add_dependency "webrick", "~> 1.8"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-global_expectations"
  spec.add_development_dependency "minitest-sprint"
  spec.add_development_dependency "rake"
end
