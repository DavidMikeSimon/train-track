class AppointmentsController < ApplicationController
  # TODO - PERMISSIONS, oi! (Hook into Hobo permissions if it isn't already being done)
  
  hobo_model_controller
  
  auto_actions :edit, :show
  
  def update
    hobo_update do
      flash[:notice] = "Attendance information for #{@appointment.person.name} updated"
      redirect_to @appointment.workshop
    end
  end

  # TODO - Make me a web method
  def toggle_print_needed
    @appt = Appointment.find(params[:id])
    @appt.print_needed = !@appt.print_needed?
    @appt.save!
    @appt.reload(:include => :attendances)
    render :update do |page|
      page.replace "appointment%u" % @appt.id, :partial => @appt
    end
  end
  
  # TODO - Make me a web method
  def toggle_registration
    @appt = Appointment.find(params[:id])
    @appt.toggle!(:registered)
    render :update do |page|
      page.replace "appointment%u" % @appt.id, :partial => @appt
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
    elem_id = "appointment#{params[:id]}"
    render :update do |page|
      page.visual_effect :fade, elem_id
    end
  end
 
  # FIXME Refactor! And also refactor the corresponding ugly view code in appointments.dryml
  def create
    @role = params[:role]
    @workshop_id = params[:workshop_id]

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
    elsif params.has_key?(:search_skipped)
      @first_name = params[:first_name].strip
      @last_name = params[:last_name].strip
    elsif params.has_key?(:first_name) && params.has_key?(:last_name) && !params.has_key?(:search_skipped)
      @first_name = params[:first_name].strip
      @last_name = params[:last_name].strip
      if @first_name == "" || @last_name == ""
        render(:text => "")
      else
        people += Person.fuzzy_find_scope("#{@first_name} #{@last_name}").all(:limit => 7)
      end
    else
      raise "Invalid params to create action"
    end
    
    if people.size == 1
      # Got one match with a person; create/find the appointment with them
      @appointment = Appointment.find_or_create_by_workshop_id_and_person_id(
        @workshop_id,
        people[0].id,
        :role => @role
      )
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_by_name_approximation"
        # Can't use page.remove because that causes an error if the element isn't already present
        # Desired behavior is to remove if it's there, but not worry if it isn't
        page.select("#appointment%u" % @appointment.id).each { |value| value.remove }
        page.insert_html :top, "#{@role}-container", :partial => @appointment
        # TODO Fade in the new element
      end
    elsif people.size > 1
      # Got several possible people; allow the user to decide who they intended
      @people = people
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_from_several_choices"
      end
    else
      # No matches; have the user create a new Person in place
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_with_new_person"
        page.hide "#{@role}-error-flash"
      end
    end
  end
end
