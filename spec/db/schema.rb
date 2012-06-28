# require File.join(File.dirname(__FILE__), 'fixtures/document')

ActiveRecord::Schema.define(:version => 0) do

  create_table "organizations", :force => true do |t|
    t.string   "name", :null => false
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
    
  create_table "attributes", :force => true do |t|
    t.integer  "user_id", :null => false
    t.integer  "field_id", :null => false
    t.string   "string_value"
    t.text     "text_value"
    t.boolean  "boolean_value"
    t.datetime "datetime_value"
    t.date     "date_value"
    t.integer  "integer_value"
    t.float    "float_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fields", :force => true do |t|
    t.string   "name", :null => false, :limit => 63
    t.string   "style", :null => false, :limit => 15
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "select_options", :force => true do |t|
    t.integer "field_id", :null => false
    t.string "option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  add_index "select_options", [:field_id, :option], :unique => true, :name => "select_options_index"
  
end
