class Post < ActiveRecord::Base
  
  has_custom_fields
  
#  validates_presence_of :intro, :message => "can't be blank", :on => :create
end