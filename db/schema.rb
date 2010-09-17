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

ActiveRecord::Schema.define(:version => 20100917183734) do

  create_table "appointments", :force => true do |t|
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "workshop_id"
    t.integer   "person_id"
    t.string    "role"
    t.integer   "institution_id"
    t.integer   "random_identifier_id"
    t.boolean   "print_needed",         :default => true
    t.boolean   "registered",           :default => false
  end

  add_index "appointments", ["institution_id"], :name => "index_appointments_on_institution_id"
  add_index "appointments", ["person_id"], :name => "index_appointments_on_person_id"
  add_index "appointments", ["random_identifier_id"], :name => "index_appointments_on_random_identifier_id"
  add_index "appointments", ["workshop_id", "person_id", "role"], :name => "index_appointments_on_workshop_id_and_person_id_and_role", :unique => true

  create_table "attendances", :force => true do |t|
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "appointment_id"
    t.integer   "workshop_session_id"
  end

  add_index "attendances", ["appointment_id"], :name => "index_attendances_on_appointment_id"
  add_index "attendances", ["workshop_session_id", "appointment_id"], :name => "index_attendances_on_workshop_session_id_and_appointment_id", :unique => true
  add_index "attendances", ["workshop_session_id"], :name => "index_attendances_on_workshop_session_id"

  create_table "institutions", :force => true do |t|
    t.string    "name"
    t.string    "school_code"
    t.integer   "region"
    t.text      "address"
    t.string    "telephone_numbers"
    t.string    "fax_number"
    t.string    "email_address"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "parish"
    t.string    "organization_type",                 :default => "school"
    t.string    "principal"
    t.string    "education_officer"
    t.integer   "female_students_total",             :default => 0
    t.integer   "male_students_total",               :default => 0
    t.integer   "female_students_early_grade_total", :default => 0
    t.integer   "male_students_early_grade_total",   :default => 0
    t.integer   "female_teachers_total",             :default => 0
    t.integer   "male_teachers_total",               :default => 0
    t.integer   "female_teachers_early_grade_total", :default => 0
    t.integer   "male_teachers_early_grade_total",   :default => 0
  end

  add_index "institutions", ["name", "region"], :name => "index_institutions_on_name_and_region", :unique => true

  create_table "jobs", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string    "first_name"
    t.string    "last_name"
    t.string    "title"
    t.string    "gender"
    t.string    "cell_number"
    t.string    "landline_number"
    t.string    "fax_number"
    t.string    "email_address"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "job_details"
    t.integer   "grade_taught"
    t.integer   "job_id"
  end

  add_index "people", ["job_id"], :name => "index_people_on_job_id"

  create_table "person_trigrams", :force => true do |t|
    t.string  "token",     :null => false
    t.integer "person_id"
  end

  add_index "person_trigrams", ["person_id"], :name => "index_person_trigrams_on_person_id"
  add_index "person_trigrams", ["token"], :name => "index_person_trigrams_on_token"

  create_table "processed_xml_files", :force => true do |t|
    t.string    "filename"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "accepted"
    t.boolean   "duplicate_entry"
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

  add_index "random_identifiers", ["random_identifier_group_id", "in_use"], :name => "index_random_identifiers_on_random_identifier_group_id_and_in_u"

  create_table "training_subjects", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "crypted_password",          :limit => 40
    t.string    "salt",                      :limit => 40
    t.string    "remember_token"
    t.timestamp "remember_token_expires_at"
    t.string    "name"
    t.string    "email_address"
    t.boolean   "administrator",                           :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "state",                                   :default => "active"
    t.timestamp "key_timestamp"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

  create_table "workshop_sessions", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "workshop_id"
    t.integer   "random_identifier_id"
    t.timestamp "starts_at"
    t.integer   "minutes",              :default => 0
    t.integer   "training_subject_id"
  end

  add_index "workshop_sessions", ["random_identifier_id"], :name => "index_workshop_sessions_on_random_identifier_id"
  add_index "workshop_sessions", ["workshop_id", "name"], :name => "index_workshop_sessions_on_workshop_id_and_name", :unique => true
  add_index "workshop_sessions", ["workshop_id"], :name => "index_workshop_sessions_on_workshop_id"

  create_table "workshops", :force => true do |t|
    t.string    "title"
    t.date      "first_day"
    t.string    "venue"
    t.integer   "region"
    t.string    "purpose"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.date      "last_day"
    t.integer   "random_identifier_id"
    t.integer   "appointment_identifier_group_id"
    t.integer   "workshop_session_identifier_group_id"
    t.integer   "default_training_subject_id"
  end

  add_index "workshops", ["appointment_identifier_group_id"], :name => "index_workshops_on_appointment_identifier_group_id"
  add_index "workshops", ["random_identifier_id"], :name => "index_workshops_on_random_identifier_id"
  add_index "workshops", ["workshop_session_identifier_group_id"], :name => "index_workshops_on_workshop_session_identifier_group_id"

end
