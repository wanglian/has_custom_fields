class CreateFieldsForUser < ActiveRecord::Migration
  def self.up
    create_table(:fields) do |t|
      t.string :name, :null => false, :limit => 63
      t.string :style, :null => false, :limit => 15
      t.integer :organization_id
      t.timestamps
    end
    add_index :fields, ["organization_id", "name"], :unique => true
    
    create_table(:attributes) do |t|
      t.integer :user_id, :null => false
      t.integer :field_id, :null => false
      t.string  :value, :null => false
      t.timestamps
    end
    
    def self.up
      create_table(:select_options) do |t|
        t.string :option, :null => false, :limit => 63
        t.integer :user_field_id
        t.timestamps
      end
      add_index :select_options, :user_field_id, :unique => false
    end
    
    add_index :attributes, ["user_id", "field_id"], :unique => true
    add_index :attributes, :user_id
    add_index :attributes, :field_id
    add_index :attributes, :value
  end

  def self.down
    drop_table(:fields)
    drop_table(:attributes)
    drop_table(:select_options)
  end
end
