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
  
  belongs_to :institution
  
  has_many :appointments, :dependent => :destroy
  
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
