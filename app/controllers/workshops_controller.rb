require 'fastercsv'
require 'set'

class WorkshopsController < ApplicationController
  hobo_model_controller
  offroad_group_controller

  auto_actions :all
  
  if Offroad::app_offline?
    skip_filter :check_for_workshop, :only => [:manage_offline, :create]
    index_action :manage_offline do
    end
  end

  def create
    if Offroad::app_offline?
      load_down_mirror_file nil, params[:file], :initial_mode => true
      flash[:notice] = "Workshop has been succesfully imported"
      redirect_to Workshop.first
    else
      hobo_create
    end
  end
    
  web_method :set_offline do
    @this.set_offline
    flash[:notice] = "Workshop is now in standalone mode"
    redirect_to @this
  end

  web_method :force_online do
    @this.force_online
    flash[:notice] = "Workshop has been forced back to online mode"
    redirect_to @this
  end

  web_method :offline_lock do
    @this.offline_lock
    flash[:notice] = "Workshop has been locked, now ready to generate data file"
    redirect_to root_path
  end

  web_method :upload_up_mirror do
    flash[:notice] = "Workshop has been updated and brought online"
    redirect_to @this
  end

  show_action :down_mirror_file do
    render_down_mirror_file Workshop.find(params[:id]), "down-mirror-file", :layout => "mirror-file", :initial_mode => true
  end
 
  show_action :csv_codes do
    csv_fields = [
      ["Region", lambda {|a| a.person.institution.try.region.to_s }],
      ["Institution", lambda {|a| a.person.institution.try.name.to_s }],
      ["BEP School", lambda {|a| a.person.institution.try.bep ? "true" : "false"}],
      ["School Code", lambda {|a| a.person.institution.try.school_code.to_s }],
      ["Role", lambda {|a| a.role }],
      ["Last Name", lambda {|a| a.person.last_name }],
      ["First Name", lambda {|a| a.person.first_name }],
      ["Cell", lambda { |a| a.person.cell_number }],
      ["Landline", lambda { |a| a.person.landline_number }],
      ["Fax", lambda { |a| a.person.fax_number }],
      ["Email", lambda { |a| a.person.email_address }],
      ["Code", lambda {|a| a.train_code }],
      ["Job", lambda {|a| a.person.job ? a.person.job.name : "Other" }],
      ["Admin", lambda {|a| a.person.job ? a.person.job.admin : "false" }],
      ["Job Details", lambda {|a| a.person.job_details }],
      ["Gender", lambda {|a| a.person.gender }],
      ["Grade Taught", lambda {|a| a.person.grade_taught }],
      ["Sessions Attended", lambda {|a| a.attendances.size }],
      ["Registered", lambda {|a| a.registered }]
    ]
    
    workshop = Workshop.find(params[:id])
    source = Appointment.all(
      :conditions => { :workshop_id => workshop.id },
      :include => [{:person => [:institution]}, :random_identifier, :attendances],
      :order => "institutions.region, institutions.name, people.last_name, people.first_name"
    )
    render_csv ("attendees-of-#{workshop.title.downcase.gsub(" ", "-")}.csv"), csv_fields, source
  end

  show_action :attendee_labels do
    # FIXME - Do a reload of the workshop page after this is done
    @workshop = Workshop.find(params[:id], :include => [:appointments])
    prawnto :inline => false, :prawn => {:page_size => 'LETTER', :margin => 0}
    render "attendee_labels.pdf", :layout => false
    @workshop.appointments.update_all("print_needed = 'f'")
  end

  # FIXME Do this as a web method even though it's not really instance specific
  show_action :process_xml do
    xml_dir = defined?(TAR2RUBYSCRIPT) ? oldlocation("attendance-xml") : "#{RAILS_ROOT}/attendance-xml"
    already_processed = Set.new(ProcessedXmlFile.connection.select_values("SELECT filename FROM processed_xml_files"))
    processed = 0
    Dir.foreach(xml_dir) do |filename|
      if filename.downcase.end_with?(".xml") && !already_processed.include?(filename)
        begin
          filepath = "%s/%s" % [xml_dir, filename]

          # FIXME Stupid hack to work around rubyscript2exe's problems with iconv decoders
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
