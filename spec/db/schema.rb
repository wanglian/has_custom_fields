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
    
  create_table "user_attributes", :force => true do |t|
    t.integer  "user_id", :null => false
    t.integer  "user_field_id", :null => false
    t.string   "value", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_fields", :force => true do |t|
    t.string   "name", :null => false, :limit => 63
    t.string   "style", :null => false, :limit => 15
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "user_field_select_options", :force => true do |t|
    t.integer "user_field_id"
    t.string "option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
    
end
