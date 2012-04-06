class User < ActiveRecord::Base
  belongs_to :organization
  has_custom_fields :scopes => [:organization]

  attr_accessible :name, :email
end