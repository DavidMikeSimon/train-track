class InstitutionsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def index
    hobo_index Institution.fuzzy_find_scope(params[:search])
  end

  index_action :csv do
    csv_fields = [
      ["Name", lambda { |s| s.name }],
      ["Region", lambda { |s| s.region.to_s }],
      ["Type", lambda { |s| s.organization_type.to_s.titleize }],
      ["School Code", lambda { |s| s.school_code.to_s }],
      ["QEC", lambda { |s| s.qec.to_s }],
      ["BEP", lambda { |s| s.bep ? "true" : "false" }],
      ["Address", lambda { |s| s.address.to_s.strip.gsub("\n", ", ").gsub("\r", "") }],
      ["Parish", lambda { |s| s.parish.to_s }],
      ["Tel Numbers", lambda { |s| s.telephone_numbers.to_s }],
      ["Fax Number", lambda { |s| s.fax_number.to_s }],
      ["Email", lambda { |s| s.email_address.to_s }],
      ["Principal", lambda { |s| s.principal.to_s }],
      ["Education Officer", lambda { |s| s.education_officer.to_s }],
      ["Female Students (Total)", lambda { |s| s.female_students_total.to_s }],
      ["Male Students (Total)", lambda { |s| s.male_students_total.to_s }],
      ["Female Students (Early Grade)", lambda { |s| s.female_students_early_grade_total.to_s }],
      ["Male Students (Early Grade)", lambda { |s| s.male_students_early_grade_total.to_s }],
      ["Female Teachers (Total)", lambda { |s| s.female_teachers_total.to_s }],
      ["Male Teachers (Total)", lambda { |s| s.male_teachers_total.to_s }],
      ["Female Teachers (Early Grade)", lambda { |s| s.female_teachers_early_grade_total.to_s }],
      ["Male Teachers (Early Grade)", lambda { |s| s.male_teachers_early_grade_total.to_s }]
    ]
    render_csv "institutions.csv", csv_fields, Institution.all(:order => "region, name")
  end
end
