class Workshop < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  validates_numericality_of(
    :region,
    :only_integer => true,
    :allow_nil => true,
    :greater_than_or_equal_to => 1,
    :less_than_or_equal_to => APP_CONFIG["regions"]
  )
  
  fields do
    title     :string, :required
    first_day :date, :required
    last_day  :date, :required
    venue     :string, :required
    region    :integer, :required
    purpose   :string
    timestamps
  end
  
  has_many :appointments, :dependent => :destroy
  has_many :people, :through => :appointments
  
  has_many :participant_appointments, :class_name => "Appointment", :conditions => { :role => "participant" }
  has_many :participants, :through => :participant_appointments, :source => :person
  
  has_many :trainer_appointments, :class_name => "Appointment", :conditions => { :role => "trainer" }
  has_many :trainers, :through => :trainer_appointments, :source => :person
  
  set_default_order "title"
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up?
  end
  
  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
