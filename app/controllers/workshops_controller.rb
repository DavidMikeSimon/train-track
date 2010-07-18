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
      Appointment.all(
        :conditions => { :workshop_id => workshop.id, :role => "participant" },
        :include => [:institution, :person, :random_identifier],
        :order => "institutions.region, institutions.name, people.last_name, people.first_name"
      ).each do |appointment|
        output.write "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n" % [
          appointment.institution.region,
          appointment.institution.name,
          appointment.person.last_name,
          appointment.person.first_name,
          appointment.train_code
        ]
      end
    }
  end
  
  # FIXME This should be a web_method, implemented in model and accessible only through POST
  show_action :process_xml do
    xml_dir = defined?(TAR2RUBYSCRIPT) ? oldlocation("attendance-xml") : "#{RAILS_ROOT}/attendance-xml"
    already_processed = Set.new(ProcessedXmlFile.connection.select_values("SELECT filename FROM processed_xml_files"))
    processed = 0
    Dir.foreach(xml_dir) do |filename|
      if filename.downcase.end_with?(".xml") && !already_processed.include?(filename)
        doc = REXML::Document.new(File.open("%s/%s" % [xml_dir, filename]))
        unaccepted = 0
        duplicated = false
        
        doc.root.elements.each do |record|  
          begin
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
            
            if workshop && workshop_session && appointment
              logger.info "%s - MARKING PRESENT - APPOINTMENT %s WITH WORKSHOP %s, SESSION %s" % [filename, appointment, workshop, workshop_session]
              begin
                Attendance.create(:appointment => appointment, :workshop_session => workshop_session)
              rescue ActiveRecord::StatementInvalid
                duplicated = true
                logger.info "ABOVE MARK IS A DUPLICATE"
              end
            else
              logger.info "%s - UNABLE TO RESOLVE INPUT (W:%s S:%s A:%s)" % [filename, workshop_code, workshop_session_code, participant_code]
              unaccepted += 1
            end
          rescue StandardError => e
            logger.info "#{filename} - UNABLE TO READ INPUT DATA : #{e.class.to_s} : #{e.to_s}"
            unaccepted += 1
          end  
        end
        
        ProcessedXmlFile.create(:filename => filename, :accepted => (unaccepted == 0), :duplicate_entry => duplicated)
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
