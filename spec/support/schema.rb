ActiveRecord::Schema.define(:version => 1) do
  create_table :people, :force => true do |t|    
    t.string   :first_name
    t.string   :last_name
    t.integer  :sex
    t.integer  :attending
    t.integer  :staying
    t.integer  :employment_status
  end

  create_table :sorted_people, :force => true do |t|
    t.string   :first_name
    t.string   :last_name
    t.integer  :sex
    t.integer  :attending
    t.integer  :staying
  end

  create_table :sexes, :force => true do |t|
    t.string :name
  end
end
