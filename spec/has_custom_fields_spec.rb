require 'spec_helper'

describe 'Has Custom Fields' do
  
  describe "class methods" do

    it "returns an empty array if there are no fields" do
      org = Organization.create!(:name => 'ABC Corp')
      User.custom_field_fields(:organization, org.id).should == []
    end

  end


end