require 'spec_helper'
require File.join(File.dirname(__FILE__), "db", "migrations", "001_has_custom_fields_select_options_migration")
require File.join(File.dirname(__FILE__), "db", "migrations", "002_migrate_custom_fields_data")
require File.join(File.dirname(__FILE__), "db", "migrations", "003_remove_custom_fields_attribute")
# select options were originally stored in the (table_name)_fields.select_options attribute.
# this spec is for testing that existing data stored in the select_options attribute is correctly migrated to it's own table

describe 'Has Custom Fields' do

  context "a user with custom fields requiring select options" do
          
    # we start off with the data structure as if it had already been migrated
    # because schema.rb needs to have the most up-to-date info for the other specs
  
    before(:each) do
      @org = Organization.create!(:name => 'ABC Corp')
      @user = User.create!(:name => 'John')
      UserField.create!(:organization_id => @org.id, :name => 'Category', :style => 'select', 
                        :user_field_select_options => [UserFieldSelectOption.create!(:option => "CatA"),
                                                       UserFieldSelectOption.create!(:option => "CatB"),
                                                       UserFieldSelectOption.create!(:option => "CatC")])
    end
  
    describe "after the migration" do
      
      it "stores the select options in the separate user_field_select_options table" do
        options = User.custom_field_fields(:organization,@org.id).first.user_field_select_options
        options.size.should == 3
        ["CatA","CatB","CatC"].each_with_index do |category,index|
          options[index].option.should == category
        end
      end
      
    end
    
    describe "migrating down" do
      
      before do
        RemoveCustomFieldsAttribute.down
        MigrateCustomFieldsData.down
        CreateCustomFieldSelectOptionsForUser.down
      end
      
      it "stores the select options as an array" do
        
        User.custom_field_fields(:organization,@org.id).first.select_options.should == "---\n- CatA\n- CatB\n- CatC\n"
      end
      
      after do
        CreateCustomFieldSelectOptionsForUser.up
        MigrateCustomFieldsData.up
        RemoveCustomFieldsAttribute.up
      end
      
    end
    
    describe "redoing the migration" do
      
      before do
        RemoveCustomFieldsAttribute.down
        MigrateCustomFieldsData.down
        CreateCustomFieldSelectOptionsForUser.down
        CreateCustomFieldSelectOptionsForUser.up
        MigrateCustomFieldsData.up
        RemoveCustomFieldsAttribute.up
      end
      
      it "stores the select options in the separate user_field_select_options table again" do
        options = User.custom_field_fields(:organization,@org.id).first.user_field_select_options
        options.size.should == 3
        ["CatA","CatB","CatC"].each_with_index do |category,index|
          options[index].option.should == category
        end
      end
      
    end
    
  end
  
end