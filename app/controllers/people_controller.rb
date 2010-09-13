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
      ["Institution", lambda { |p| p["institution_name"] }],
      ["Region", lambda { |p| p["institution_region"] }],
      ["Gender", lambda { |p| p.gender }],
      ["Job", lambda {|p| p.job ? p.job.name : "Other" }]
    ]
    
    TrainingSubject.all.each do |ts|
      csv_fields << ["%s Hours" % ts.name, lambda { |p| (p["#{ts.name}_minutes"] || 0)/60.0}]
    end
    
    csv_fields << ["Total Hours", lambda { |p| (p["total_minutes"] || 0)/60.0}]
   
    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n")
      
      # Header
      csv << csv_fields.map {|e| e[0]}

      select_fields = ["people.*"]
      # TODO Get rid of this silly hack once people are more closely associated with an institution
      ["name", "region"].each { |institution_field|
        select_fields << "(SELECT institutions.#{institution_field} FROM appointments LEFT JOIN institutions ON institutions.id = appointments.institution_id LEFT JOIN workshops ON workshops.id = appointments.workshop_id WHERE appointments.person_id = people.id ORDER BY workshops.first_day DESC LIMIT 1) AS institution_#{institution_field}"
      }
      TrainingSubject.all.each { |ts|
        select_fields << Person.minute_count_select_expr("%s_minutes" % ts.name, ts)
      }
      select_fields << Person.minute_count_select_expr("total_minutes")

      # Content
      Person.all(:select => select_fields.join(","), :order => "last_name, first_name").each { |person|
        csv << csv_fields.map {|e| (e[1].call(person) || "").to_s}
      }
    }
  end

end
