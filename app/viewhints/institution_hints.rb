class InstitutionHints < Hobo::ViewHints
  field_names :female_students_total => "Female Students (All Grades)",
              :male_students_total => "Male Students (All Grades)",
              :female_students_early_grade_total => "Female Students (Grades 1-3)",
              :male_students_early_grade_total => "Male Students (Grades 1-3)"
  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
end