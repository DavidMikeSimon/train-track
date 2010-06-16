class Appointment < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  Role = HoboFields::EnumString.for(:participant, :trainer)
  
  fields do
    role        Appointment::Role
    timestamps
  end
  
  validates_presence_of :workshop, :person, :institution
  
  belongs_to :workshop, :index => false # Index would duplicate the multi-column index below
  belongs_to :person
  belongs_to :institution
  
  index [:workshop_id, :person_id, :role], :unique => true
  
  def self.possible_institutions(role)
    org_type = case role
      when "participant" then "school"
      when "trainer" then "training_organization"
      else raise "Invalid role"
    end
    return Institution.find(:all, :conditions => {:organization_type => org_type}, :order => :name)
  end
  
  def self.find_or_update_or_create_by_ids(workshop_id, person_id, institution_id, role)
    appointment = Appointment.find_by_workshop_id_and_person_id_and_role(workshop_id, person_id, role)
    if appointment
      if appointment.institution_id != institution_id
        appointment.institution_id = institution_id
        appointment.save!
      end
      return appointment
    else
      return Appointment.create(
        :workshop_id => workshop_id,
        :person_id => person_id,
        :institution_id => institution_id,
        :role => role
      )
    end
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up?
  end

  def destroy_permitted?
    acting_user.signed_up?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
