require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize!

#require 'rspec/rails'

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
