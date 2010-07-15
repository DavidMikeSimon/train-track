class Attendance < ActiveRecord::Base
  
  hobo_model # Don't put anything above this
  
  fields do
    timestamps
  end
  
  belongs_to :appointment, :counter_cache => true
  has_one :person, :through => :appointment
  belongs_to :workshop_session, :counter_cache => true
  
  validates_presence_of :appointment, :workshop_session
  
  index [:workshop_session_id, :appointment_id], :unique => true
  
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