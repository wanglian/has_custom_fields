class CreateFieldsForUser < ActiveRecord::Migration
  def self.up
    create_table(:fields) do |t|
      t.string :name, :null => false, :limit => 63
      t.string :style, :null => false, :limit => 15
      t.string :kind
      t.integer :organization_id
      t.integer :user_id
      t.timestamps
    end
    
    create_table(:field_attributes) do |t|
      t.integer :user_id, :null => false
      t.integer :field_id, :null => false
      t.string   :string_value
      t.boolean  :boolean_value
      t.date     :date_value
      t.float    :decimal_value
      t.timestamps
    end
    add_index :field_attributes, ["user_id", "field_id"], :unique => true
    add_index :field_attributes, :user_id
    add_index :field_attributes, :field_id
    add_index :field_attributes, :string_value
    add_index :field_attributes, :boolean_value
    add_index :field_attributes, :date_value
    add_index :field_attributes, :decimal_value
    create_table(:field_select_options) do |t|
      t.string :name, :null => false, :limit => 63
      t.integer :field_id
      t.timestamps
    end
    add_index :field_select_options, :field_id, :unique => false

  end

  def self.down
    drop_table(:fields)
    drop_table(:field_attributes)
    drop_table(:field_select_options)
  end
end
