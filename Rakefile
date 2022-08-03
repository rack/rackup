# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

desc "Run all the tests"
task default: :test

Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/spec_*.rb"]
  t.warning = false
  t.verbose = true
end
