require 'spec_helper'

describe "Extends active record" do

  it "should have many attributes" do
    post = Post.create({
      title: 'Hello World',
      body: 'This is my first blog post. Great!'
    })
    # make a proper assertion but this currently fails if has_custom_fields does not exist...
  end
  
end
