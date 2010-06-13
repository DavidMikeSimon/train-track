class Appointment < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  Role = HoboFields::EnumString.for(:participant, :trainer)
  
  fields do
    role        Appointment::Role
    timestamps
  end
  
  validates_presence_of :workshop, :person
  
  belongs_to :workshop, :index => false # Index would duplicate the multi-column index below
  belongs_to :person
  
  index [:workshop_id, :person_id], :unique => true

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
    true
  end

end
