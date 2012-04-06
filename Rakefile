require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "has_custom_fields"
    gem.summary = %Q{The easy way to add custom fields to any Rails model.}
    gem.description = %Q{Uses a vertical schema to add custom fields.}
    gem.email = "kylejginavan@gmail.com"
    gem.homepage = "http://github.com/kylejginavan/has_custom_fields"
    gem.add_dependency('builder')
    gem.authors = ["kylejginavan"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "has_custom_fields (or a dependency) not available. Install it with: gem install has_custom_fields"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "constantations #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
