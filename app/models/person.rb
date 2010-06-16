class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  Title = HoboFields::EnumString.for("Mr.", "Mrs.", "Miss", "Ms.", "Dr.", "Rev.", "Sister", "Fr.")
  Gender = HoboFields::EnumString.for(:male, :female)
  
  validates_presence_of :institution
  
  fields do
    first_name      :string, :required
    last_name       :string, :required
    title           Person::Title, :required
    gender          Person::Gender, :required
    cell_number     :string
    landline_number :string
    fax_number      :string
    email_address   :email_address
    timestamps
  end
    
  # This is just the last known institution that this person belongs to.
  # The school they represented at the time of a given workshop is recorded in Appointment
  belongs_to :institution
  has_many :appointments, :dependent => :destroy
  
  index [:first_name, :last_name, :institution_id], :unique => true
  
  
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
  
  def name
    "#{last_name}, #{first_name}"
  end

end
