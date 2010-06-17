class AppointmentsController < ApplicationController
  def create
    @role = params[:role]
    @workshop_id = params[:workshop_id]
    @institution_id = params[:institution_id]
    
    people = []
    if params.has_key?(:first_name) && params.has_key?(:last_name)
      @first_name = params[:first_name].strip
      @last_name = params[:last_name].strip
      render(:text => "") if @first_name == "" || @last_name == ""
      
      # TODO : Do a fuzzy search; implement it as a Person method
      people = Person.find(:all, :conditions => { :first_name => @first_name, :last_name => @last_name})
    elsif params.has_key?(:person_id)
      people << Person.find(params[:person_id])
    else
      render(:text => "")
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
        # Can't just use "page.remove" because that errors out if the id isn't already present
        page.select("#appointment-%u" % @appointment.id).each do |value|
          value.remove
        end
        page.insert_html :top, "#{@role}-container", :partial => @appointment
      end
    elsif people.size > 1
      # Got several possible people; allow the user to decide who they intended
    else
      # No matches; have the user create a new Person in place
      render :update do |page|
        page.replace_html "#{@role}-insertion-form", :partial => "new_with_new_person"
      end
    end
  end
end