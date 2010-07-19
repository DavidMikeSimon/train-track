class AppointmentsController < ApplicationController
  # TODO - When bringing back the name approximation form, show the same institution as before
  # TODO - PERMISSIONS, oi! (Hook into Hobo permissions if it isn't already being done)
  
  hobo_model_controller
  
  auto_actions :edit
  
  def update
    hobo_update do
      flash[:notice] = "Attendance information for #{@appointment.person.name} updated"
      redirect_to @appointment.workshop
    end
  end
  
  # TODO - Make me a web method
  def toggle_registration
    @appt = Appointment.find(params[:id])
    @workshop = Workshop.find(@appt.workshop_id)
    # FIXME Don't use a hard-coded name
    @workshop_session = WorkshopSession.find_by_workshop_id_and_name(@workshop.id, "Conference Registration")
   
    if @workshop_session
      attendance = @appt.attendances.find_by_workshop_session_id(@workshop_session.id)
      if attendance
        attendance.destroy
      else
        Attendance.create(:appointment => @appt, :workshop_session => @workshop_session)
      end
    end
    
    @appt.reload(:include => :attendances)
    render :update do |page|
      page.replace "appointment-%u" % @appt.id, :partial => @appt
    end
  end
  
  def cancel_new_person_creation
    @role = params[:role]
    @workshop_id = params[:workshop_id]
    render :update do |page|
      page.replace_html "#{@role}-insertion-form", :partial => "new_by_name_approximation"
    end
  end
  
  def destroy
    Appointment.destroy(params[:id])
    elem_id = "appointment-#{params[:id]}"
    render :update do |page|
      page.visual_effect :fade, elem_id
    end
  end
  
  def create
    @role = params[:role]
    @workshop_id = params[:workshop_id]
    @institution_id = params[:institution_id]
    
    people = []
    if params.has_key?(:create_new_person) && params[:create_new_person]
      person = Person.new(Hash[params.select {|key, value| Person.column_names.include?(key.to_s)}])
      if person.valid?
        person.save!
        people << person
      else
        flash_id = "#{@role}-error-flash"
        render :update do |page|
          page.show flash_id
          page.replace_html flash_id, person.errors.full_messages.join("<br/>")
        end
        return
      end
    elsif params.has_key?(:person_id)
      people << Person.find(params[:person_id])
    elsif params.has_key?(:first_name) && params.has_key?(:last_name)
      @first_name = params[:first_name].strip
      @last_name = params[:last_name].strip
      render(:text => "") if @first_name == "" || @last_name == ""
      # TODO : Do a fuzzy search; implement it as a Person method
      people = Person.find(:all, :conditions => { :first_name => @first_name, :last_name => @last_name})
    else
      raise "Invalid params to create action"
    end
    
    if people.size == 1
      # Got one match with a person; create/find the appointment with them
      # TODO If given institution differs from person's last known institution, ask user if they want to move the person or make new person
      @appointment = Appointment.find_or_update_or_create_by_ids(
        @workshop_id,
        people[0].id,
        @institution_id,
        @role
      )
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_by_name_approximation"
        # Can't use page.remove because that causes an error if the element isn't already present
        # Desired behavior is to remove if it's there, but not worry if it isn't
        page.select("#appointment-%u" % @appointment.id).each { |value| value.remove }
        page.insert_html :top, "#{@role}-container", :partial => @appointment
        # TODO Fade in the new element
      end
    elsif people.size > 1
      # Got several possible people; allow the user to decide who they intended
      raise "Not yet implemented"
    else
      # No matches; have the user create a new Person in place
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_with_new_person"
        page.hide "#{@role}-error-flash"
      end
    end
  end
end
