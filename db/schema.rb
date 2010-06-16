# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100615193358) do

  create_table "appointments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workshop_id"
    t.integer  "person_id"
    t.string   "role"
    t.integer  "institution_id"
  end

  add_index "appointments", ["institution_id"], :name => "index_appointments_on_institution_id"
  add_index "appointments", ["person_id"], :name => "index_appointments_on_person_id"
  add_index "appointments", ["workshop_id", "person_id"], :name => "index_appointments_on_workshop_id_and_person_id", :unique => true

  create_table "institutions", :force => true do |t|
    t.string   "name"
    t.string   "school_code"
    t.integer  "region"
    t.text     "address"
    t.string   "telephone_numbers"
    t.string   "fax_number"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parish"
    t.string   "organization_type", :default => "school"
    t.string   "principal"
    t.string   "education_officer"
  end

  add_index "institutions", ["name", "region"], :name => "index_institutions_on_name_and_region", :unique => true

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "gender"
    t.string   "cell_number"
    t.string   "landline_number"
    t.string   "fax_number"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "institution_id"
  end

  add_index "people", ["first_name", "last_name", "institution_id"], :name => "index_people_on_first_name_and_last_name_and_institution_id", :unique => true
  add_index "people", ["institution_id"], :name => "index_people_on_institution_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workshops", :force => true do |t|
    t.string   "title"
    t.date     "first_day"
    t.string   "venue"
    t.integer  "region"
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "last_day"
  end

end
