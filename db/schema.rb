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

ActiveRecord::Schema.define(:version => 20100719182612) do

  create_table "appointments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workshop_id"
    t.integer  "person_id"
    t.string   "role"
    t.integer  "institution_id"
    t.integer  "random_identifier_id"
  end

  add_index "appointments", ["institution_id"], :name => "index_appointments_on_institution_id"
  add_index "appointments", ["person_id"], :name => "index_appointments_on_person_id"
  add_index "appointments", ["random_identifier_id"], :name => "index_appointments_on_random_identifier_id"

  create_table "attendances", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "appointment_id"
    t.integer  "workshop_session_id"
  end

  add_index "attendances", ["appointment_id"], :name => "index_attendances_on_appointment_id"
  add_index "attendances", ["workshop_session_id", "appointment_id"], :name => "index_attendances_on_workshop_session_id_and_appointment_id", :unique => true
  add_index "attendances", ["workshop_session_id"], :name => "index_attendances_on_workshop_session_id"

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
  end

  create_table "processed_xml_files", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted"
    t.boolean  "duplicate_entry"
  end

  create_table "random_identifier_groups", :force => true do |t|
    t.string  "name"
    t.integer "max_value"
  end

  add_index "random_identifier_groups", ["name"], :name => "index_random_identifier_groups_on_name", :unique => true

  create_table "random_identifiers", :force => true do |t|
    t.integer "identifier"
    t.boolean "in_use",                     :default => false
    t.integer "random_identifier_group_id"
  end

  add_index "random_identifiers", ["random_identifier_group_id", "in_use", "id"], :name => "index_random_identifiers_on_random_identifier_group_and_in_use_and_id"
  add_index "random_identifiers", ["random_identifier_group_id"], :name => "index_random_identifiers_on_random_identifier_group_id"

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

  create_table "workshop_sessions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workshop_id"
    t.integer  "random_identifier_id"
    t.datetime "starts_at"
  end

  add_index "workshop_sessions", ["random_identifier_id"], :name => "index_workshop_sessions_on_random_identifier_id"
  add_index "workshop_sessions", ["workshop_id", "name"], :name => "index_workshop_sessions_on_workshop_id_and_name", :unique => true
  add_index "workshop_sessions", ["workshop_id"], :name => "index_workshop_sessions_on_workshop_id"

  create_table "workshops", :force => true do |t|
    t.string   "title"
    t.date     "first_day"
    t.string   "venue"
    t.integer  "region"
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "last_day"
    t.integer  "random_identifier_id"
    t.integer  "appointment_identifier_group_id"
    t.integer  "workshop_session_identifier_group_id"
  end

  add_index "workshops", ["appointment_identifier_group_id"], :name => "index_workshops_on_appointment_identifier_group_id"
  add_index "workshops", ["random_identifier_id"], :name => "index_workshops_on_random_identifier_id"
  add_index "workshops", ["workshop_session_identifier_group_id"], :name => "index_workshops_on_workshop_session_identifier_group_id"

end
