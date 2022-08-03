# frozen_string_literal: true

require_relative 'lib/rackup/version'

Gem::Specification.new do |spec|
  spec.name = "rackup"
  spec.version = Rackup::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.author = "Rack Contributors"
  spec.summary = "A general server command for Rack applications."
  spec.license = "MIT"

  spec.files = Dir.glob('{bin,lib}/**/*', base: __dir__)

  spec.require_path = 'lib'

  spec.homepage = 'https://github.com/rack/rackup'

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'rack'
  spec.add_dependency 'webrick'

  spec.add_development_dependency 'minitest', "~> 5.0"
  spec.add_development_dependency 'minitest-sprint'
  spec.add_development_dependency 'minitest-global_expectations'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
