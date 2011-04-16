class WorkshopSessionsController < ApplicationController

  hobo_model_controller

  auto_actions :edit
  
  def update
    hobo_update do
      redirect_to @workshop_session.workshop
    end
  end
  
  def destroy
    hobo_destroy do
      redirect_to @workshop_session.workshop
    end
  end
  
  def create
    @workshop_id = params[:workshop_id]
    @name = params[:name]
    @minutes = params[:minutes]
    date_parts = params[:start_date].split("-").map(&:to_i)
    @starts_at = DateTime.new(
      date_parts[0],
      date_parts[1],
      date_parts[2],
      params[:start_hour].to_i,
      params[:start_minute].to_i,
      0
    )
    @workshop_session = WorkshopSession.create(:workshop_id => @workshop_id, :starts_at => @starts_at, :minutes => @minutes, :name => @name)
    if @workshop_session then
      render :update do |page|
        page.insert_html :top, "workshop-session-container", :partial => @workshop_session
      end
    else
      render nil
    end
  end
  
  show_action :attendance_form do
    @workshop_session = WorkshopSession.find(params[:id], :include => [:workshop])
    prawnto :inline => false, :prawn => {:page_size => 'LEGAL', :margin => 0}
    render "attendance_form.pdf", :layout => false
  end

  show_action :csv do
    csv_fields = [
      ["Region", lambda {|a| a.person.institution.try.region.to_s }],
      ["Institution", lambda {|a| a.person.institution.try.name.to_s }],
      ["BEP School", lambda {|a| a.person.institution.try.bep ? "true" : "false"}],
      ["School Code", lambda {|a| a.person.institution.try.school_code.to_s }],
      ["QEC", lambda {|a| a.person.institution.try.qec.to_s }],
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
      ["Registered", lambda {|a| a.registered }]
    ]
    
    workshop_session = WorkshopSession.find(params[:id], :include => [:workshop])
    source = Appointment.all(
      :conditions => { :workshop_id => workshop_session.workshop.id },
      :include => [{:person => [:institution]}, :random_identifier, :attendances],
      :order => "institutions.region, institutions.name, people.last_name, people.first_name"
    )
    filename = "attendees-of-session-#{workshop_session.description.parameterize}.csv"
    source = source.select{|appt| appt.attendances.any?{|att| att.workshop_session_id == workshop_session.id}}
    render_csv filename, csv_fields, source
  end

end
