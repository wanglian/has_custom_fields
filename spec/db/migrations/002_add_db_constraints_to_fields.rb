class add_db_constraints_to_fields < ActiveRecord::Migration
  
  def self.up
    # add fk constraint on field_select_options
    add_foreign_key :select_options, :fields
    # add_index with uniq constraint :select_options_table_name, [:field_id, :option], :unique => true
    add_index :select_options, [:user_field_id, :option], :unique => true, :name => "user_field_options_index"
    # add :null => false on select_options_table_name.field_id
    change_column :select_options, :user_field_id, :integer, :null => false
  end

  def self.down
    remove_foreign_key :select_options, :name => "user_field_select_options_user_field_id_fk"
    remove_index :select_options, :name => "user_field_options_index"
    change_column :select_options, :user_field_id, :integer
  end
end