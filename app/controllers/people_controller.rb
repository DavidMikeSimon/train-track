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
 
  # TODO Should probably just make this format-detected on regular index action
  # TODO Adjust this once people are more closely associated with an institution
  # TODO Factor out this streaming-CSV-generation idea and have workshop CSV use it too
  index_action :csv do
    filename = "people.csv"
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end
  
    csv_fields = [
      ["Last Name", lambda { |p| p.last_name }],
      ["First Name", lambda { |p| p.first_name }],
      #["Institution", lambda { |p| p.appointments.last.institution.name if p.appointments.last }],
      #["Region", lambda { |p| p.appointments.last.institution.region if p.appointments.last }],
      ["Gender", lambda { |p| p.gender }],
      ["Job", lambda {|p| p.job ? p.job.name : "Other" }],
      ["Job Details", lambda {|p| p.job_details }]
    ]
    
    TrainingSubject.all.each do |ts|
      csv_fields << ["%s Hours" % ts.name, lambda { |p| (p.send("#{ts.name}_minutes") || 0)/60.0}]
    end
    
    csv_fields << ["Total Hours", lambda { |p| (p.send("total_minutes") || 0)/60.0}]
   
    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n")
      
      # Header
      csv << csv_fields.map {|e| e[0]}

      select_fields = ["people.*"]
      TrainingSubject.all.each do |ts|
        select_fields << Person.minute_count_select_expr("%s_minutes" % ts.name, ts)
      end
      select_fields << Person.minute_count_select_expr("total_minutes")

      # Content
      Person.all(:select => select_fields.join(","), :order => "last_name, first_name").each do |person|
        csv << csv_fields.map {|e| (e[1].call(person) || "").to_s}
      end
    }
  end

end
