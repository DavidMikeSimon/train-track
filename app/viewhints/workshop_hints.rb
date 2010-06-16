class WorkshopHints < Hobo::ViewHints
  children :participant_appointments, :trainer_appointments
  field_names :trainer_appointments => "Trainers", :participant_appointments => "Participants"
  
  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
end
