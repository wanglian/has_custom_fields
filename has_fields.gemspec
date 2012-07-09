# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'has_fields/version'

Gem::Specification.new do |s|
  s.name = %q{has_fields}
  s.version = HasFields::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["kylejginavan"]
  s.date = %q{2012-02-21}
  s.description = %q{Uses a vertical schema to add fields.}
  s.email = %q{kylejginavan@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Rakefile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "has_fields.gemspec",
    "lib/has_fields/base.rb",
    "lib/has_fields/class_methods.rb",
    "lib/has_fields/engine.rb",
    "lib/has_fields/instance_methods.rb",
    "lib/has_fields/version.rb",
    "lib/has_fields.rb",
    "spec/db/database.yml",
    "spec/db/schema.rb",
    "spec/test_models/user.rb",
    "spec/test_models/organization.rb",
    "spec/has_fields_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/kylejginavan/has_fields}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{The easy way to add custom fields to any Rails model.}

  s.add_dependency('activerecord', ['>= 3.1.0'])
  s.add_development_dependency('rspec')
  s.add_development_dependency('database_cleaner')
  s.add_development_dependency('sqlite3')
end
