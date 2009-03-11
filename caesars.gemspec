@spec = Gem::Specification.new do |s|
  s.name = %q{caesars}
  s.version = "0.5.0"
  s.date = %q{2009-03-05}
  s.specification_version = 1 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.authors = ["Delano Mandelbaum"]
  s.description = %q{A simple class for rapid DSL prototyping in Ruby.}
  s.summary = %q{Caesars: A simple class for rapid DSL prototyping in Ruby.}
  s.email = %q{delano@solutious.com}

  # = MANIFEST =
  # git ls-files
  s.files = %w(
  CHANGES.txt
  LICENSE.txt
  README.rdoc
  Rakefile
  bin/example
  bin/example.bat
  bin/party.conf
  caesars.gemspec
  lib/caesars.rb
  )

  #  s.add_dependency ''

  s.has_rdoc = true
  s.homepage = %q{http://github.com/delano/caesar}
  s.extra_rdoc_files = %w[README.rdoc LICENSE.txt CHANGES.txt]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Caesars: A simple class for rapid DSL prototyping in Ruby.", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.1.1}
  s.rubyforge_project = "caesars"
end
