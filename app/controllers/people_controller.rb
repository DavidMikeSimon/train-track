class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  
  def index
  	hobo_index Person.fuzzy_find_scope(params[:search])
  end
 
  # TODO Should probably just make this format-detected on regular index action
  index_action :csv do
    csv_fields = [
      ["Last Name", lambda { |p| p.last_name }],
      ["First Name", lambda { |p| p.first_name }],
      ["Region", lambda { |p| p.appointments.last.institution.region if p.appointments.last }]
    ]

    csv_data = FasterCSV.generate do |csv|
      # Header
      csv << csv_fields.map {|e| e[0]}

      # Content
      Person.all(
        :order => "last_name, first_name"
      ).each do |person|
        csv << csv_fields.map {|e| e[1].call(person) || ""}
      end
    end
    
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=\"participants-%s.csv\"" % params[:limit]
  end

end
