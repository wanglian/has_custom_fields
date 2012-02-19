class User < ActiveRecord::Base
  has_custom_fields :scopes => [:organization]
end