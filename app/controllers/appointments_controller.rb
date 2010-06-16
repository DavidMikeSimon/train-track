class AppointmentsController < ApplicationController
  def new_disambiguate_person
  end
  
  def new_creating_person
  end
  
  def create
    logger.info "A"
    person = Person.find_by_first_name_and_last_name_and_institution_id(
      params[:first_name],
      params[:last_name],
      params[:institution_id]
    )
    if p
      logger.info "B"
      appointment = Appointment.create(
        :workshop_id => params[:workshop_id],
        :person_id => person.id,
        :institution_id => params[:institution_id]
      )
      logger.info "C"
      redirect_to :show, :id => p.id
    else
      logger.info "D"
      redirect_to :action => :new_disambiguate_person
    end
  end
  
  def show
  end
end