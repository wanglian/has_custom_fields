class User < ActiveRecord::Base
  belongs_to :organization
  has_fields :scopes => [:organization], :db_tables_prefix => ""

  attr_accessible :name, :email
end