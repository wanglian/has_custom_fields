require "active_support"
require "active_record"
require "database_cleaner"

# Establish DB Connection
config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'db', 'database.yml')))
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

# Load Test Schema into the Database
load(File.dirname(__FILE__) + "/db/schema.rb")

require File.dirname(__FILE__) + '/../init'

# Load in the test models

require File.dirname(__FILE__) + '/test_models/person'
require File.dirname(__FILE__) + '/test_models/document'
require File.dirname(__FILE__) + '/test_models/post'
require File.dirname(__FILE__) + '/test_models/preference'


RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
