class RemoveFieldsAttribute < ActiveRecord::Migration
  
  def self.up
    remove_column :user_fields, :select_options
  end

  def self.down
    add_column :user_fields, :select_options, :string
  end
end