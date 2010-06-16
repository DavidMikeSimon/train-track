class AppointmentsController < ApplicationController
  def create
    @role = params[:role]
    @workshop = params[:workshop]
    
    people = []
    if params.has_key?(:first_name) && params.has_key?(:last_name)
      # TODO : Do a fuzzy search; implement it as a Person method
      people = Person.find(:all, :conditions => { :first_name => params[:first_name], :last_name => params[:last_name]})
    elsif params.has_key :person_id
      people << Person.find(params[:person_id])
    end
    
    if people.size == 1
      # Got one match with a person; create/find the appointment with them
      # TODO If given institution differs from person's last known institution, ask user if they want to move the person or make new person
      @appointment = Appointment.find_or_update_or_create_by_ids(
        params[:workshop_id],
        people[0].id,
        params[:institution_id],
        params[:role]
      )
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_by_name_approximation"
        page.remove "appointment-%u" % @appointment.id
        page.insert_html :top, "#{@role}-container", :partial => @appointment
      end
    elsif people.size > 1
      # Got several possible people; allow the user to decide who they intended
    else
      # No matches; have the user create a new Person in place
    end
  end
  
  def index
    render :partial => "appointment", :collection => Appointment.find_by_workshop_id_and_role(params[:workshop_id], params[:role])
  end
end