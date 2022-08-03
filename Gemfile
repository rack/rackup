# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem "rack", git: "https://github.com/rack/rack.git", branch: "extract-rackup"

group :maintenance, optional: true do
  gem "bake"
  gem "bake-gem"

  gem "rubocop", require: false
  gem "rubocop-packaging", require: false
end

group :doc do
  gem 'rdoc'
end
