require 'spec_helper'

describe 'Has Fields' do

  context "with no fields defined" do
  
    describe "class methods" do

      it "raises an error if missing a scope to the has_fields class" do
        class TestUser < ActiveRecord::Base; end
        expect {
          TestUser.send(:has_fields)
        }.to raise_error(ArgumentError, 'Must define :scope => [] on the has_fields class method')
      end

      it "returns an empty array" do
        org = Organization.create!(:name => 'ABC Corp')
        User.fields(org).should == []
      end

      it "raise an error if the scoped object doesn't exist" do
        expect {
          User.fields(nil)
        }.to raise_error(ArgumentError, 'Please provide a scope for the fields, eg Advisor.fields(@organization)')
        
      end

      it "raises an exception if the scope doesn't exist" do
        expect {
          User.fields(Hash.new)  
        }.to raise_error(HasFields::InvalidScopeError, 'Class user does not have scope :hash defined for has_fields')
      end

    end

    describe "instance methods" do

      before(:each) do
        @org = Organization.create!(:name => 'ABC Corp')
        @user = User.create!(:name => 'Mikel')       
      end

      it "raises an exception if the field does not exist" do
        expect {
          @user.fields[:organization][@org.id]['High Potential']
        }.to raise_error(ActiveRecord::RecordNotFound, 'No field High Potential for organization 1')
      end

    end

  end

  describe "creating fields" do

    it "creates the fields" do
      @org = Organization.create!(:name => 'ABC Corp')
      expect {
        Field.create!(:organization_id => @org.id, :name => 'Value', :style => 'text')
      }.to change(HasFields::Field, :count).by(1)
    end

  end

  context "with fields defined" do

    before(:each) do
      @org = Organization.create!(:name => 'ABC Corp')
      Field.create!(:organization_id => @org.id, :name => 'Value', :style => 'text')
      Field.create!(:organization_id => @org.id, :name => 'Customer', :style => 'checkbox')
      user_field = Field.new(:organization_id => @org.id, :name => 'Category', :style => 'select')
      user_field.save(:validate => false)
      opt_a = FieldSelectOption.create!(:option => "CatA", :field => user_field)
      opt_b = FieldSelectOption.create!(:option => "CatB", :field => user_field)
      opt_c = FieldSelectOption.create!(:option => "CatC", :field => user_field)      
    end

    describe "class methods" do

      it "returns an array of UserFields" do
        User.fields(@org).length.should == 3
        values = User.fields(@org).map(&:name)
        values.should include('Customer')
        values.should include('Value')
        values.should include('Category')
      end
      
      it "returns an array of select options" do
        select_options = User.fields(@org).last.select_options.map(&:option)
        select_options.should == ["CatA","CatB","CatC"]
      end
      
      it "should return an array of select options" do
        select_options = User.fields(@org).last.select_options_data
        select_options.should == ["CatA","CatB","CatC"]
      end
      
      it "should set up the has_many and belongs_to relationships" do
        User.fields(@org).first.respond_to?(:select_options).should == true
        User.fields(@org).last.select_options.first.respond_to?(:field).should == true
      end

    end

    describe "instance methods" do

      before(:each) do
        @user = User.create!(:name => 'Mikel', :organization => @org)
      end

      it "sets attributes accessible on the fields virtual attribute" do
        @user.update_attributes(:name => 'Mikel', :email => 'mikel@example.org',
                                :fields => {:organization => {@org.id => {'Value' => '10000'}}})
        @user.name.should == 'Mikel'
        @user.email.should == 'mikel@example.org'
        @user.fields[:organization][@org.id]['Value'].should_not be_nil
      end

      it "returns nil if there is no value defined" do
        @user.fields[:organization][@org.id]['Customer'].should be_nil
        @user.fields[:organization][@org.id]['Value'].should be_nil
      end

      it "sets the value of the field and persists it in the database" do
        expect {
          @user.update_attributes(:fields => {:organization => {@org.id => {'Value' => '10000', 'Customer' => '1'}}})
          @user.fields[:organization][@org.id]['Customer'].should == true
          @user.fields[:organization][@org.id]['Value'].should == '10000'
        }.to change(FieldAttribute, :count).by(2)
      end

      it "does not persist in the database if the value is nil or blank" do
        expect {
          @user.update_attributes(:fields => {:organization => {@org.id => {'Value' => '', 'Customer' => nil}}})
          @user.fields[:organization][@org.id]['Customer'].should be_nil
          @user.fields[:organization][@org.id]['Value'].should be_nil
        }.to change(FieldAttribute, :count).by(0)
      end

      it "deletes the value from the database if the value is nil or blank" do
        @user.update_attributes(:fields => {:organization => {@org.id => {'Value' => '10000', 'Customer' => '1'}}})

        expect {
          @user.update_attributes(:fields => {:organization => {@org.id => {'Value' => '', 'Customer' => nil}}})
          @user.fields[:organization][@org.id]['Customer'].should be_nil
          @user.fields[:organization][@org.id]['Value'].should be_nil
        }.to change(FieldAttribute, :count).by(-2)
      end

    end

  end
  
  context "with select options" do
  
    describe "validations" do

      it "raises an error if there are duplicate select options" do
        @org = Organization.create!(:name => 'ABC Corp')
        user_field = Field.new(:organization_id => @org.id, :name => "Category", :style => "select")
        user_field.save(:validate => false)
        FieldSelectOption.create!(:option => "CatA", :field => user_field)
        FieldSelectOption.create!(:option => "CatB", :field => user_field)

        expect {
          FieldSelectOption.create!(:option => "CatA", :field_id => 1)
        }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Option There should not be any duplicate select options.')
      end
      
    end
    
  end

end