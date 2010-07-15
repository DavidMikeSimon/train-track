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
        doc = REXML::Document.new(File.open("%s/%s" % [xml_dir, filename]))
        doc.root.elements.each do |record|
          # FIXME Ye gods but there's too much cut and paste here
          workshop_code = record.elements["Field[@id='Workshop']/Value"].text
          workshop = Workshop.find_by_random_identifier_id(
            RandomIdentifierGroup.find_by_name("workshops").find_used_identifier(TrainCode::decode(workshop_code[1, workshop_code.size])[0]).id
          )
          
          workshop_session = nil
          appointment = nil
          if workshop
            workshop_session_code = record.elements["Field[@id='WorkshopSession']/Value"].text
            workshop_session = WorkshopSession.find_by_random_identifier_id(
              workshop.workshop_session_identifier_group.find_used_identifier(TrainCode::decode(workshop_session_code[1, workshop_code.size])[0]).id
            )
            
            participant_code = record.elements["Field[@id='Attendee']/Value"].text
            appointment = Appointment.find_by_random_identifier_id(
              workshop.appointment_identifier_group.find_used_identifier(TrainCode::decode(participant_code)[0]).id
            )
          end
          
          accepted = false
          duplicated = false
          if workshop && workshop_session && appointment
            accepted = true
            logger.info "MARKING PRESENT - APPOINTMENT %s WITH WORKSHOP %s, SESSION %s" % [appointment, workshop, workshop_session]
            begin
              Attendance.create(:appointment => appointment, :workshop_session => workshop_session)
            rescue ActiveRecord::StatementInvalid
              duplicated = true
              logger.info "ABOVE MARK IS A DUPLICATE"
            end
          else
            logger.info "UNABLE TO RESOLVE INPUT (W:%s S:%s A:%s)" % [workshop_code, workshop_session_code, participant_code]
          end
          
          ProcessedXmlFile.create(:filename => filename, :accepted => accepted, :duplicate_entry => duplicated)
        end
        
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
