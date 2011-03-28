class Attendance < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  
  belongs_to :appointment
  has_one :person, :through => :appointment
  
  belongs_to :workshop_session, :index => false
  
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

  acts_as_offroadable :group_owned, :parent => :workshop_session
end
