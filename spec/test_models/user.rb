class User < ActiveRecord::Base
  belongs_to :organization
  has_custom_fields :scopes => [:organization]
end