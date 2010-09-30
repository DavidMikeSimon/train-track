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
      ["Cell", lambda { |p| p.cell_number }],
      ["Landline", lambda { |p| p.landline_number }],
      ["Fax", lambda { |p| p.fax_number }],
      ["Email", lambda { |p| p.email_address }],
      ["Institution", lambda { |p| p.institution.try.name }],
      ["Region", lambda { |p| p.institution.try.region }],
      ["BEP", lambda { |p| p.institution.try.bep }],
      ["School Code", lambda { |p| p.institution.try.school_code }],
      ["Gender", lambda { |p| p.gender }],
      ["Job", lambda {|p| p.job ? p.job.name : "Other" }],
      ["Job Details", lambda {|p| p.job_details }]
    ]
    TrainingSubject.all.each do |ts|
      Workshop.all.each do |w|
        if w.workshop_sessions.any?{|s| s.training_subject == ts}
          csv_fields << ["%s Attended" % w.title, lambda { |p| p.first_session_attended(ts,w).try.starts_at.try.strftime('%Y-%m-%d') }]
          csv_fields << ["%s %s Hours" % [w.title, ts.name.upcase], lambda { |p| p.hours_attended(ts, w) }] 
        end
      end
      csv_fields << ["Total %s Hours" % ts.name.upcase, lambda { |p| p.hours_attended(ts) }]
    end
    csv_fields << ["Grand Total Hours", lambda { |p| p.hours_attended}]
    
    render_csv "people.csv", csv_fields, Person.sorted_by_last_name.including_all_associations
  end

end
