require 'spec_helper'

describe 'Has Custom Fields' do

  context "with no fields defined" do
  
    describe "class methods" do

      it "returns an empty array if there are no fields" do
        org = Organization.create!(:name => 'ABC Corp')
        User.custom_field_fields(:organization, org.id).should == []
      end

      it "returns an empty array if the scoped object doesn't exist" do
        User.custom_field_fields(:organization, nil).should == []
      end

      it "raises an exception if the scope doesn't exist" do
        expect {
          User.custom_field_fields(:something, nil)  
        }.to raise_error(ActiveRecord::HasCustomFields::InvalidScopeError, 'Class User does not have scope :something defined for has_custom_fields')
      end

    end

    describe "instance methods" do

      before(:each) do
        @org = Organization.create!(:name => 'ABC Corp')
        @user = User.create!(:name => 'Mikel')       
      end

      it "raises an exception if the field does not exist" do
        expect {
          @user.custom_fields[:organization][@org.id]['High Potential']
        }.to raise_error(ActiveRecord::RecordNotFound, 'No field High Potential for organization 1')
      end

    end

  end


end