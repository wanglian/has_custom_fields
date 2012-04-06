class MigrateCustomFieldsData < ActiveRecord::Migration

  class UserField < ActiveRecord::Base
    serialize :select_options
    has_many :user_field_select_options
  end
  class UserFieldSelectOption < ActiveRecord::Base
    belongs_to :user_field
  end
  
  def self.up
    # extract the existing data out of user_fields.select_options and into the new table
    UserField.reset_column_information
    UserField.all.each do |custom_field|
      custom_field.select_options.to_a.each do |option|
        UserFieldSelectOption.create!(:user_field_id => custom_field.id, :option => option)
      end
    end
  end

  def self.down
    # get the data out of user_field_select_options and put it back into the user_fields.select_options attribute
    UserField.reset_column_information
    UserField.all.each do |custom_field|
      if !custom_field.user_field_select_options.empty?
        custom_field.update_attributes(:select_options => custom_field.user_field_select_options.map(&:option))
      end
    end
  end
end