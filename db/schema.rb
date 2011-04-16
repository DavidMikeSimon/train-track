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

ActiveRecord::Schema.define(:version => 20110415210810) do

  create_table "appointments", :force => true do |t|
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "workshop_id"
    t.integer   "person_id"
    t.string    "role"
    t.integer   "random_identifier_id"
    t.boolean   "print_needed",         :default => true
    t.boolean   "registered",           :default => false
  end

  add_index "appointments", ["person_id"], :name => "index_appointments_on_person_id"
  add_index "appointments", ["random_identifier_id"], :name => "index_appointments_on_random_identifier_id"

  create_table "attendances", :force => true do |t|
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "appointment_id"
    t.integer   "workshop_session_id"
  end

  add_index "attendances", ["appointment_id"], :name => "index_attendances_on_appointment_id"
  add_index "attendances", ["workshop_session_id", "appointment_id"], :name => "index_attendances_on_workshop_session_id_and_appointment_id", :unique => true

  create_table "institution_trigrams", :force => true do |t|
    t.string  "token",          :null => false
    t.integer "institution_id"
  end

  add_index "institution_trigrams", ["institution_id"], :name => "index_institution_trigrams_on_institution_id"
  add_index "institution_trigrams", ["token"], :name => "index_institution_trigrams_on_token"

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
    t.boolean   "bep",                               :default => false
    t.string    "qec"
  end

  add_index "institutions", ["name", "region"], :name => "index_institutions_on_name_and_region", :unique => true

  create_table "jobs", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "admin",      :default => false
  end

  create_table "offroad_group_states", :force => true do |t|
    t.integer  "app_group_id",                                         :null => false
    t.boolean  "group_being_destroyed",         :default => false,     :null => false
    t.boolean  "group_locked",                  :default => false,     :null => false
    t.integer  "confirmed_group_data_version",                         :null => false
    t.integer  "confirmed_global_data_version",                        :null => false
    t.datetime "last_installer_downloaded_at"
    t.datetime "last_installation_at"
    t.datetime "last_down_mirror_created_at"
    t.datetime "last_down_mirror_loaded_at"
    t.datetime "last_up_mirror_created_at"
    t.datetime "last_up_mirror_loaded_at"
    t.integer  "launcher_version"
    t.integer  "app_version"
    t.string   "operating_system",              :default => "Unknown", :null => false
  end

  add_index "offroad_group_states", ["app_group_id"], :name => "index_offroad_group_states_on_app_group_id", :unique => true
  add_index "offroad_group_states", ["confirmed_global_data_version"], :name => "index_offroad_group_states_on_confirmed_global_data_version"

  create_table "offroad_model_states", :force => true do |t|
    t.string "app_model_name", :null => false
  end

  add_index "offroad_model_states", ["app_model_name"], :name => "index_offroad_model_states_on_app_model_name", :unique => true

  create_table "offroad_received_record_states", :force => true do |t|
    t.integer "model_state_id",                  :null => false
    t.integer "group_state_id",   :default => 0, :null => false
    t.integer "local_record_id",                 :null => false
    t.integer "remote_record_id",                :null => false
  end

  create_table "offroad_sendable_record_states", :force => true do |t|
    t.integer "model_state_id",                     :null => false
    t.integer "local_record_id",                    :null => false
    t.integer "mirror_version",  :default => 0,     :null => false
    t.boolean "deleted",         :default => false, :null => false
  end

  create_table "offroad_system_state", :force => true do |t|
    t.integer "current_mirror_version"
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
    t.string    "grade_taught"
    t.integer   "job_id"
    t.integer   "institution_id"
  end

  add_index "people", ["institution_id"], :name => "index_people_on_institution_id"
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
    t.integer "random_identifier_group_id"
  end

  add_index "random_identifiers", ["random_identifier_group_id"], :name => "index_random_identifiers_on_random_identifier_group_id"

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
