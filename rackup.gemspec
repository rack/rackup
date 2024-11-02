# frozen_string_literal: true

require_relative "lib/rackup/version"

Gem::Specification.new do |spec|
  spec.name = "rackup"
  spec.version = Rackup::VERSION
  
  spec.summary = "A general server command for Rack applications."
  spec.authors = ["Samuel Williams", "James Tucker", "Leah Neukirchen", "Jeremy Evans", "Joshua Peek", "Megan Batty", "Rafael França", "Anurag Priyam", "Max Cantor", "Michael Fellinger", "Sophie Deziel", "Yoshiyuki Hirano", "Aaron Patterson", "Jean Boussier", "Katsuhiko Yoshida", "Konstantin Haase", "Krzysztof Rybka", "Martin Hrdlicka", "Nick LaMuro", "Aaron Pfeifer", "Akira Matsuda", "Andrew Bortz", "Andrew Hoglund", "Bas Vodde", "Blake Mizerany", "Carl Lerche", "David Celis", "Dillon Welch", "Genki Takiuchi", "Geremia Taglialatela", "Hal Brodigan", "Hrvoje Šimić", "Igor Bochkariov", "Jeremy Kemper", "Joe Fiorini", "John Barnette", "John Sumsion", "Julik Tarkhanov", "Kang Sheng", "Kazuya Hotta", "Lenny Marks", "Loren Segal", "Marc-André Cournoyer", "Misaki Shioi", "Olle Jonsson", "Peter Wilmott", "Petrik de Heus", "Richard Schneeman", "Ryunosuke Sato", "Sean McGivern", "Stephen Paul Weber", "Tadashi Saito", "Tim Moore", "Timur Batyrshin", "Trevor Wennblom", "Tsutomu Kuroda", "Uchio Kondo", "Wyatt Pan", "Yehuda Katz", "Zachary Scott"]
  spec.license = "MIT"

  spec.homepage = "https://github.com/rack/rackup"

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/rack/rackup.git",
  }

  spec.files = Dir["{bin,lib}/**/*", "*.md"]

  spec.executables = ["rackup"]

  spec.required_ruby_version = ">= 2.5"

  spec.add_dependency "rack", ">= 3"
end
