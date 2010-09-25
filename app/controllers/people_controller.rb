class ActionController::Response
  def <<(s)
    write(s)
  end
end

class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  
  def index
  	hobo_index Person.fuzzy_find_scope(params[:search])
  end
 
  index_action :csv do
    csv_fields = [
      ["Last Name", lambda { |p| p.last_name }],
      ["First Name", lambda { |p| p.first_name }],
      ["Institution", lambda { |p| p["institution_name"] }],
      ["Region", lambda { |p| p["institution_region"] }],
      ["BEP", lambda { |p| p["institution_bep"] }],
      ["School Code", lambda { |p| p["institution_school_code"] }],
      ["Gender", lambda { |p| p.gender }],
      ["Job", lambda {|p| p.job ? p.job.name : "Other" }],
      ["Job Details", lambda {|p| p.job_details }]
    ]
    TrainingSubject.all.each do |ts|
      csv_fields << ["%s Hours" % ts.name, lambda { |p| (p["%s_minutes" % ts.name.gsub(" ", "_").underscore].to_i || 0)/60.0}]
    end
    csv_fields << ["Total Hours", lambda { |p| (p["total_minutes"].to_i || 0)/60.0}]
    
    render_csv "people.csv", csv_fields, Person.with_minute_count_fields.sorted_by_last_name
  end

end
