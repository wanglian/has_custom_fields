ActiveRecord::Schema.define do  
  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
    t.integer :organization_id
  end
  
  create_table :organizations, :force => true do |t|
    t.string :name
  end
end
