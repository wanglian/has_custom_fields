class AddDbConstraintsToCustomFields < ActiveRecord::Migration
  
  def self.up
	  # add fk constraint on custom_field_select_options
	  # not supported on sqlite3:
	  # add_foreign_key :user_field_select_options, :user_fields
	  # add_index with uniq constraint :select_options_table_name, [:custom_field_id, :option], :unique => true
	  add_index :user_field_select_options, [:user_field_id, :option], :unique => true, :name => "user_field_options_index"
    # add :null => false on select_options_table_name.custom_field_id
  	change_column :user_field_select_options, :user_field_id, :integer, :null => false
  end

  def self.down
    # not supported on sqlite3:
	  # remove_foreign_key :user_field_select_options, :name => "user_field_select_options_user_field_id_fk"
	  remove_index :user_field_select_options, :name => "user_field_options_index"
    change_column :user_field_select_options, :user_field_id, :integer	
  end
end