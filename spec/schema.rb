ActiveRecord::Schema.define(:version => 1) do

  create_table :people, :force => true do |t|    
    t.string   :first_name
    t.string   :last_name
    t.integer  :sex
    t.integer  :attending
    t.integer  :staying
  end

  create_table :sexes, :force => true do |t|
    t.string :name
  end

  create_table :enums, :force => true do |t|
    t.integer :enum_id
    t.string :name
    t.string :enum_type
    t.datetime :modified_at
  end
  add_index :enums, [:enum_id, :enum_type]
  add_index :enums, [:name, :enum_type]
  add_index :enums, [:modified_at, :enum_type]

end
