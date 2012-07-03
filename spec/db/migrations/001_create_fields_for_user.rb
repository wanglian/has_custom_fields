class CreateFieldsForUser < ActiveRecord::Migration
  def self.up
    create_table(:fields) do |t|
      t.string :name, :null => false, :limit => 63
      t.string :style, :null => false, :limit => 15
      t.integer :organization_id
      t.timestamps
    end
    add_index :fields, ["organization_id", "name"], :unique => true
    
    create_table(:field_attributes) do |t|
      t.integer :user_id, :null => false
      t.integer :field_id, :null => false
      t.string   :string_value
      t.boolean  :boolean_value
      t.date     :date_value
      t.timestamps
    end
    add_index :field_attributes, ["user_id", "field_id"], :unique => true
    add_index :field_attributes, :user_id
    add_index :field_attributes, :field_id
    add_index :field_attributes, :value
        
    create_table(:field_select_options) do |t|
      t.string :option, :null => false, :limit => 63
      t.integer :user_field_id
      t.timestamps
    end
    add_index :field_select_options, :user_field_id, :unique => false

  end

  def self.down
    drop_table(:fields)
    drop_table(:field_attributes)
    drop_table(:field_select_options)
  end
end
