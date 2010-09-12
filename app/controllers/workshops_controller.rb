require 'fastercsv'
require 'set'

class WorkshopsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  show_action :csv_codes do
    workshop = Workshop.find(params[:id])
    conditions = { :workshop_id => workshop.id, :role => "participant" }
    conditions[:print_needed] = true if params[:limit] == "print"
    conf_registration_session = workshop.workshop_sessions.find_by_name('Conference Registration')
    
    csv_fields = [
      ["Region", lambda {|a| a.institution.region }],
      ["Institution", lambda {|a| a.institution.name }],
      ["Last Name", lambda {|a| a.person.last_name }],
      ["First Name", lambda {|a| a.person.first_name }],
      ["Code", lambda {|a| a.train_code }],
      ["Job", lambda {|a| a.person.job ? a.person.job.name : "Other" }],
      ["Job Details", lambda {|a| a.person.job_details }],
      ["Gender", lambda {|a| a.person.gender }],
      ["Grade Taught", lambda {|a| a.person.grade_taught }],
      ["Regular Sessions Attended", lambda {|a| a.non_registration_attendances_count(conf_registration_session) }],
      ["Registered", lambda {|a| a.attendances.any?{|a| a.workshop_session_id == conf_registration_session.id } }]
    ]
    
    csv_data = FasterCSV.generate do |csv|
      # Header
      csv << csv_fields.map {|e| e[0]}
     
      # Content
      Appointment.all(
        :conditions => conditions,
        :include => [:institution, :person, :random_identifier, :attendances],
        :order => "institutions.region, institutions.name, people.last_name, people.first_name"
      ).each do |appointment|
        csv << csv_fields.map {|e| e[1].call(appointment)}
      end
    end
    
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=\"participants-%s.csv\"" % params[:limit]

    # This has to be in the render proc block, otherwise it's executed _before_ the render
    if params[:limit] == "print"
      workshop.appointments.update_all("print_needed = 'f'")
    end
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
