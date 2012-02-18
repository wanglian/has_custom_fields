require 'rubygems'
require 'rake'

task :default => :test

task :test do
  sh("bundle exec rspec spec") { |ok, res| }
end

