require 'csv'
require 'set'

class WorkshopsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  show_action :csv_codes do
    headers['Content-Disposition'] = "attachment; filename=\"participants.csv\""
    headers['Content-Type'] = 'text/csv'
    
    workshop = Workshop.find(params[:id])
    render :text => proc { |response, output|
      workshop.participant_appointments.find_in_batches(:include => [:person, :random_identifier]) do |batch|
        batch.each do |appointment|
          output.write "\"%s\",\"%s\"\n" % [appointment.person, appointment.train_code]
        end
      end
    }
  end
  
  # FIXME This should be a web_method, accessible only through POST, since it has side effects
  show_action :process_xml do
    xml_dir = defined?(TAR2RUBYSCRIPT) ? oldlocation("attendance-xml") : "#{RAILS_ROOT}/attendance-xml"
    already_processed = Set.new(ProcessedXmlFile.connection.select_values("SELECT filename FROM processed_xml_files"))
    processed = 0
    Dir.foreach(xml_dir) do |filename|
      if filename.downcase.end_with?(".xml") && !already_processed.include?(filename)
        processed += 1
      end
    end
    
    if processed > 0
      flash[:notice] = "Successfully processed %u new attendance entries" % processed
    else
      flash[:notice] = "No new attendance entries to process"
    end
    redirect_to Workshop.find(params[:id])
  end

end
