require 'spec_helper'

describe 'Has Custom Fields' do

  context "with no fields defined" do
  
    describe "class methods" do

      it "returns an empty array" do
        org = Organization.create!(:name => 'ABC Corp')
        User.custom_field_fields(:organization, org.id).should == []
      end

      it "returns an empty array if the scoped object doesn't exist" do
        User.custom_field_fields(:organization, nil).should == []
      end

      it "raises an exception if the scope doesn't exist" do
        expect {
          User.custom_field_fields(:something, nil)  
        }.to raise_error(HasCustomFields::InvalidScopeError, 'Class User does not have scope :something defined for has_custom_fields')
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

  context "creating fields" do

    it "creates the fields" do
      @org = Organization.create!(:name => 'ABC Corp')
      expect {
        UserField.create!(:organization_id => @org.id, :name => 'Value', :style => 'text')
      }.to change(HasCustomFields::UserField, :count).by(1)
    end

  end

  context "with fields defined" do

    before(:each) do
      @org = Organization.create!(:name => 'ABC Corp')
      UserField.create!(:organization_id => @org.id, :name => 'Value', :style => 'text')
      UserField.create!(:organization_id => @org.id, :name => 'Customer', :style => 'text')
    end

    describe "class methods" do

      it "returns an array of UserFields" do
        User.custom_field_fields(:organization, @org.id).length.should == 2
        values = User.custom_field_fields(:organization, @org.id).map(&:name)
        values.should include('Customer')
        values.should include('Value')
      end

    end

    describe "instance methods" do

      before(:each) do
        @user = User.create!(:name => 'Mikel', :organization => @org)
      end

      it "returns nil if there is no value defined" do
        @user.custom_fields[:organization][@org.id]['Customer'].should be_nil
        @user.custom_fields[:organization][@org.id]['Value'].should be_nil
      end

    end

  end


end