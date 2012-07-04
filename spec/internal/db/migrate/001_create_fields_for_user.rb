class CreateFieldsForUser < ActiveRecord::Migration
  def self.up
    create_table(:fields) do |t|
      t.string :name, :null => false, :limit => 63
      t.string :style, :null => false, :limit => 15
      t.integer :organization_id
      t.timestamps
    end
    add_index :fields, ["organization_id", "name"], :unique => true
    
    create_table(:fields_attributes) do |t|
      t.integer :user_id, :null => false
      t.integer :field_id, :null => false
      t.string   :string_value
      t.boolean  :boolean_value
      t.date     :date_value
      t.timestamps
    end
    add_index :fields_attributes, ["user_id", "field_id"], :unique => true
    add_index :fields_attributes, :user_id
    add_index :fields_attributes, :field_id
    add_index :fields_attributes, :string_value
    add_index :fields_attributes, :boolean_value
    add_index :fields_attributes, :date_value
        
    create_table(:fields_select_options) do |t|
      t.string :option, :null => false, :limit => 63
      t.integer :field_id
      t.timestamps
    end
    add_index :fields_select_options, :field_id, :unique => false

  end

  def self.down
    drop_table(:fields)
    drop_table(:fields_attributes)
    drop_table(:fields_select_options)
  end
end
