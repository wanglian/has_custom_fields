require 'spec_helper'



describe "Extends active record" do
  
  before(:all) do
    class Post < ActiveRecord::Base
      has_custom_fields
    end
  end
  
  it "should have many attributes" do
    post = Post.create({
      title: 'Hello World',
      body: 'This is my first blog post. Great!'
    })
    # make a proper assertion but this currently fails if has_custom_fields does not exist...
  end
  
  
  
  
end
