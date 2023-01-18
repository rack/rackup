# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
  gem "bake"
  gem "bake-gem"
  gem "bake-modernize"

  gem "rubocop", require: false
  gem "rubocop-packaging", require: false
end

group :doc do
  gem 'rdoc'
end

group :test do
  gem "bake-test"
  gem "bake-test-external"
end
