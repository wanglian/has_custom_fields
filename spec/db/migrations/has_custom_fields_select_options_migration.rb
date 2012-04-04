class CreateCustomFieldSelectOptions < ActiveRecord::Migration
  
  class UserField < ActiveRecord::Base
    serialize :select_options
    has_many :user_field_select_options
  end
  class UserFieldSelectOption < ActiveRecord::Base
    belongs_to :user_field
  end

  def self.up
    create_table(:user_field_select_options) do |t|
      t.string :option, :null => false, :limit => 63
      t.integer :user_field_id
      t.timestamps
    end
    add_index :user_field_select_options, :user_field_id, :unique => false
    
    # extract the existing data out of user_fields.select_options and into the new table
    UserField.all.each do |custom_field|
      custom_field.select_options.each do |option|
        UserFieldSelectOption.create!(:user_field_id => custom_field.id, :option => option)
      end
    end
        
    raise "Data wasn't migrated successfully" unless UserField.all.collect{|c| c.select_options }.flatten.compact.size == UserFieldSelectOption.count
    
    # drop the old column
    remove_column :user_fields, :select_options
    
  end

  def self.down
    add_column :user_fields, :select_options, :string
    UserField.reset_column_information
    # get the data out of user_field_select_options and put it back into the user_fields.select_options attribute
    UserField.all.each do |custom_field|
      if custom_field.user_field_select_options
        custom_field.update_attributes!(:select_options => custom_field.user_field_select_options.map(&:option))
      end
    end
    
    drop_table :user_field_select_options
  end
end