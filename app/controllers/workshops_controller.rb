require 'csv'
require 'set'

class WorkshopsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  show_action :csv_codes do
    line_template = "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n"
    
    workshop = Workshop.find(params[:id])
    conditions = { :workshop_id => workshop.id, :role => "participant" }
    conditions[:print_needed] = true if params[:limit] == "print"
    
    headers['Content-Disposition'] = "attachment; filename=\"participants-%s.csv\"" % params[:limit]
    headers['Content-Type'] = 'text/csv'
    
    render :text => proc { |response, output|
      output.write line_template % [
        "Region",
        "Institution",
        "Last Name",
        "First Name",
        "Code",
        "Attendances"
      ]
      
      Appointment.all(
        :conditions => conditions,
        :include => [:institution, :person, :random_identifier, :attendances],
        :order => "institutions.region, institutions.name, people.last_name, people.first_name"
      ).each do |appointment|
        output.write line_template % [
          appointment.institution.region,
          appointment.institution.name,
          appointment.person.last_name,
          appointment.person.first_name,
          appointment.train_code,
          appointment.attendances.size
        ]
      end
      
      # This has to be in the render proc block, otherwise it's executed _before_ the render
      if params[:limit] == "print"
        workshop.appointments.update_all("print_needed = 'f'")
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
        begin
		  filepath = "%s/%s" % [xml_dir, filename]
		  
		  # Stupid hack to work around rubyscript2exe's problems with iconv decoders
          fdata = File.foreach(filepath).reject{ |line| line.start_with? "<?xml" }.join("\n")
          doc = REXML::Document.new(fdata)
          unaccepted = 0
          duplicated = false
          
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
          end
	    rescue StandardError => e
		  logger.info "#{filename} - UNABLE TO READ INPUT DATA : #{e.class.to_s} : #{e.to_s}"
		  unaccepted += 1
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
