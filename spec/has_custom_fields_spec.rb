require 'spec_helper'

describe 'Has Custom Fields' do

  context "with no fields defined" do
  
    describe "class methods" do

      it "raises an error if missing a scope to the has_custom_fields class" do
        class TestUser < ActiveRecord::Base; end
        expect {
          TestUser.send(:has_custom_fields)
        }.to raise_error(ArgumentError, 'Must define :scope => [] on the has_custom_fields class method')
      end

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

  describe "creating fields" do

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
      UserField.create!(:organization_id => @org.id, :name => 'Customer', :style => 'checkbox')
      UserField.create!(:organization_id => @org.id, :name => 'Category', :style => 'select',
                        :user_field_select_options => [UserFieldSelectOption.create!(:option => 'CatA'),
                                           UserFieldSelectOption.create!(:option => 'CatB'),
                                           UserFieldSelectOption.create!(:option => 'CatC')])
    end

    describe "class methods" do

      it "returns an array of UserFields" do
        User.custom_field_fields(:organization, @org.id).length.should == 3
        values = User.custom_field_fields(:organization, @org.id).map(&:name)
        values.should include('Customer')
        values.should include('Value')
        values.should include('Category')
      end
      
      it "returns an array of select options" do
        select_options = User.custom_field_fields(:organization, @org.id).last.user_field_select_options.map(&:option)
        select_options.should == ["CatA","CatB","CatC"]
      end
      
      it "should return a comma seperated list of options" do
        select_options = User.custom_field_fields(:organization, @org.id).last.select_options_data
        select_options.should == "CatA,CatB,CatC"
      end
      
      it "should set up the has_many and belongs_to relationships" do
        User.custom_field_fields(:organization, @org.id).first.respond_to?(:user_field_select_options).should == true
        User.custom_field_fields(:organization, @org.id).last.user_field_select_options.first.respond_to?(:user_field).should == true
      end

    end

    describe "instance methods" do

      before(:each) do
        @user = User.create!(:name => 'Mikel', :organization => @org)
      end

      it "sets attributes accessible on the custom_fields virtual attribute" do
        @user.update_attributes(:name => 'Mikel', :email => 'mikel@example.org',
                                :custom_fields => {:organization => {@org.id => {'Value' => '10000'}}})
        @user.name.should == 'Mikel'
        @user.email.should == 'mikel@example.org'
        @user.custom_fields[:organization][@org.id]['Value'].should_not be_nil
      end

      it "returns nil if there is no value defined" do
        @user.custom_fields[:organization][@org.id]['Customer'].should be_nil
        @user.custom_fields[:organization][@org.id]['Value'].should be_nil
      end

      it "sets the value of the field and persists it in the database" do
        expect {
          @user.update_attributes(:custom_fields => {:organization => {@org.id => {'Value' => '10000', 'Customer' => '1'}}})
          @user.custom_fields[:organization][@org.id]['Customer'].should == '1'
          @user.custom_fields[:organization][@org.id]['Value'].should == '10000'
        }.to change(UserAttribute, :count).by(2)
      end

      it "does not persist in the database if the value is nil or blank" do
        expect {
          @user.update_attributes(:custom_fields => {:organization => {@org.id => {'Value' => '', 'Customer' => nil}}})
          @user.custom_fields[:organization][@org.id]['Customer'].should be_nil
          @user.custom_fields[:organization][@org.id]['Value'].should be_nil
        }.to change(UserAttribute, :count).by(0)
      end

      it "deletes the value from the database if the value is nil or blank" do
        @user.update_attributes(:custom_fields => {:organization => {@org.id => {'Value' => '10000', 'Customer' => '1'}}})

        expect {
          @user.update_attributes(:custom_fields => {:organization => {@org.id => {'Value' => '', 'Customer' => nil}}})
          @user.custom_fields[:organization][@org.id]['Customer'].should be_nil
          @user.custom_fields[:organization][@org.id]['Value'].should be_nil
        }.to change(UserAttribute, :count).by(-2)
      end

    end

  end


end