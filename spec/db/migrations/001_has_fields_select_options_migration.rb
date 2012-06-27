class CreateFieldSelectOptionsForUser < ActiveRecord::Migration
  
  def self.up
    create_table(:user_field_select_options) do |t|
     t.string :option, :null => false, :limit => 63
     t.integer :user_field_id
     t.timestamps
    end
    add_index :user_field_select_options, :user_field_id, :unique => false
  end

  def self.down
    drop_table(:user_field_select_options)
  end
end