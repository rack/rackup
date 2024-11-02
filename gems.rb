# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
  gem "bake"
  gem "bake-gem"
  gem "bake-modernize"

  if RUBY_VERSION >= "3.1"
    gem "bake-releases"
  end
end

group :doc do
  gem 'rdoc'
end

group :test do
  gem "bake-test"
  gem "bake-test-external"

  gem "webrick", "~> 1.8"
  gem "minitest", "~> 5.0"
  gem "minitest-global_expectations"
  gem "minitest-sprint"
  gem "rake"
end
