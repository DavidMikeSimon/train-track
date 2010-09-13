class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  
  def index
  	hobo_index Person.fuzzy_find_scope(params[:search])
  end
 
  # TODO Should probably just make this format-detected on regular index action
  # TODO Adjust this once people are more closely associated with an institution
  index_action :csv do
    csv_fields = [
      ["Last Name", lambda { |p| p.last_name }],
      ["First Name", lambda { |p| p.first_name }],
      ["Institution", lambda { |p| p.appointments.last.institution if p.appointments.last }],
      ["Region", lambda { |p| p.appointments.last.institution.region if p.appointments.last }],
      ["Gender", lambda { |p| p.gender }],
      ["Job", lambda {|p| p.job ? p.job.name : "Other" }],
      ["Job Details", lambda {|p| p.job_details }]
    ]
    
    TrainingSubject.all.each do |ts|
      csv_fields << ["%s Hours" % ts.name, lambda { |p| p.attendances.select{|a| a.workshop_session.training_subject == ts}.sum{|a| a.workshop_session.minutes}/60.0}]
    end
    
    csv_fields << ["Total Hours", lambda { |p| p.attendances.all.sum{|a| a.workshop_session.minutes}/60.0}]
    
    csv_data = FasterCSV.generate do |csv|
      # Header
      csv << csv_fields.map {|e| e[0]}

      # Content
      Person.all(
        :order => "last_name, first_name"
      ).each do |person|
        csv << csv_fields.map {|e| (e[1].call(person) || "").to_s}
      end
    end
    
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=\"people.csv\""
  end

end
