require 'spec_helper'
  
describe "#has_fields" do
  
  let(:organization) { Organization.make! }
  
  it "raises an error if missing a scope to the has_fields class" do
    expect {
      Advisor.send(:has_fields)
    }.to raise_error(ArgumentError, 'Must define :scope => [] on the has_fields class method')
  end
  
  it "raise an error if the scoped object doesn't exist" do
    expect {
      Advisor.fields(nil)
    }.to raise_error(ArgumentError, 'Please provide a scope for the fields, eg Advisor.fields(@organization)')
  end
  
  it "raises an exception if the scope doesn't exist" do
    expect {
      Advisor.fields(Hash.new)  
    }.to raise_error(HasFields::InvalidScopeError, 'Class Advisor does not have scope :hash defined for has_fields')
  end
  
  it "should provide a default set of options"
  
end
  
describe HasFields::Field do
  
  let(:user) { User.make! }
  let(:organization) { Organization.make! }
  let(:another_organization) { Organization.make! }
  let(:field) { Field.make!(:organization_id => organization.id, :name => 'Value', :style => 'text', :kind => "User") }
  
  it "should have many field_attributes" do
    Field.reflect_on_association(:field_attributes).should be_true
  end
  
  it "should have many field_select_options" do
    Field.reflect_on_association(:field_select_options).should be_true
  end
  
  it "should belong to the calling class" do
    Field.reflect_on_association(:user).should_not be_nil
  end
  
  context "validations" do
    
    it "should require a unique name (scoped by the calling class)" do
      expect {
        Field.create!(:organization_id => another_organization.id, :name => 'Value', :style => 'text', :kind => "User")
      }.to change(HasFields::Field, :count).by(1)
      expect {
        Field.create!(:organization_id => another_organization.id, :name => 'Value', :style => 'checkbox', :kind => "Something")
      }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Name The field name is already taken.')
    end
    
    it "should require a kind" do
      expect {
        Field.create!(:organization_id => organization.id, :name => 'Value', :style => 'checkbox')
      }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Kind Please specify the class that this field will be added to.')
    end
    
    it "should be one of the allowed styles"
    
  end
  
  it "should return the object it is scoped by" do
    field.scoped_by_object.should == organization
  end
  
  it "should return the class it is scoped by" do
    field.scoped_by_class.should == "organization"
  end
  
  it "should return a collection of fields with a specified scope" do
    Field.scoped_by(organization).should == [field]
  end
  
  it "should handle setting of the scope_id by storing it in the appropriate column" do
    field.organization_id.should == organization.id
    field.scope_id = "organization_#{another_organization.id}"
    field.organization_id.should == another_organization.id
  end
  
  context "with select options" do
    
    let(:field) { Field.make!(:organization_id => organization.id, :name => 'Value', :style => 'select', :kind => "User") }
    let(:option_a) { FieldSelectOption.create!(:option => "Option A", :field => field) }
    let(:option_b) { FieldSelectOption.create!(:option => "Option b", :field => field) }
    
    it "should return an array of select options data"
    
  end
  
end

describe HasFields::FieldAttribute do
  
  let(:organization) { Organization.make! }
  let(:user) { User.make!(:organization => organization) }
  let(:field) { HasFields::Field.create!(:name => "Value", :style => "text", :kind => "User", :organization_id => organization.id) }
  let(:field_attribute) { HasFields::FieldAttribute.create!(:field => field, :value => "One Million", :user => user)}
  
  it "should belong to a field" do
    HasFields::FieldAttribute.reflect_on_association(:field).should be_true
  end
  
  it "should belong to an instance of the calling class" do
    field_attribute.field.should_not be_nil
  end
  
  it "should return a stored value" do
    field_attribute.value.should == "One Million"
  end
  
  it "should handle setting the value by storing it in the appropriate column" do
    field_attribute.string_value == "One Million"
  end
  
  it "should return a data type based on what style of the field" do
    field_attribute.data_type_from_field_style.should == "string"
  end
  
  describe "validations" do
    
    it "should be invalid without a field" do
      expect {
        HasFields::FieldAttribute.create!(:user_id => user.id, :string_value => 'One Million Dollars')
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Field can't be blank")
    end
    
    it "should be invalid if the field style is select and the value is not the the select options (and not nil)" do
      field.update_attributes(:style => "select")
      HasFields::FieldSelectOption.create!(:option => "Option A", :field_id => field.id)
      expect {
        HasFields::FieldAttribute.create!(:field_id => field.id, :user_id => user.id, :value => 'Option B')
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Value is not included in the list")
    end
    
  end
  
end

describe HasFields::FieldSelectOption do
  
  let(:organization) { Organization.make! }
  let(:user) { User.make!(:organization => organization) }
  let(:field) { HasFields::Field.create!(:name => "Value", :style => "select", :kind => "User", :organization_id => organization.id) }
  let(:field_select_option_a) { HasFields::FieldSelectOption.create!(:field => field, :option => "Option A")}
  let(:field_select_option_b) { HasFields::FieldSelectOption.create!(:field => field, :option => "Option B")}
  
  it "should belong to a field" do
    field_select_option_a.field.should == field
  end
  
  context "validations" do
    
    it "should be invalid if the option is blank" do
      expect {
        HasFields::FieldSelectOption.create!(:field_id => field.id)
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Option The select option cannot be blank.")
    end
    
    it "should be invalid if the option is a duplicate"
    
  end
  
end

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
        }.to raise_error(HasFields::InvalidScopeError, 'Class User does not have scope :hash defined for has_fields')
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
        Field.create!(:organization_id => @org.id, :name => 'Value', :style => 'text', :kind => "User")
      }.to change(HasFields::Field, :count).by(1)
    end

  end

  context "with fields defined" do

    before(:each) do
      @org = Organization.create!(:name => 'ABC Corp')
      Field.create!(:organization_id => @org.id, :name => 'Value', :style => 'text', :kind => "User")
      Field.create!(:organization_id => @org.id, :name => 'Customer', :style => 'checkbox', :kind => "User")
      user_field = Field.new(:organization_id => @org.id, :name => 'Category', :style => 'select', :kind => "User")
      user_field.save(:validate => false)
      opt_a = FieldSelectOption.create!(:option => "CatA", :field_id => user_field.id)
      opt_b = FieldSelectOption.create!(:option => "CatB", :field => user_field)
      opt_c = FieldSelectOption.create!(:option => "CatC", :field => user_field)      
    end

    describe "class methods" do

      it "returns an array of UserFields" do
        User.fields(@org).size.should == 3
        values = User.fields(@org).map(&:name)
        values.should include('Customer')
        values.should include('Value')
        values.should include('Category')
      end
      
      it "returns an array of select options" do
        select_options = User.fields(@org).last.field_select_options.map(&:option)
        select_options.should == ["CatA","CatB","CatC"]
      end
      
      it "should return an array of select options" do
        select_options = User.fields(@org).last.select_options_data
        select_options.should == ["CatA","CatB","CatC"]
      end
      
      it "should set up the has_many and belongs_to relationships" do
        User.fields(@org).first.respond_to?(:field_select_options).should == true
        User.fields(@org).last.field_select_options.first.respond_to?(:field).should == true
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