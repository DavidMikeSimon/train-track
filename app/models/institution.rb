class Institution < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  validates_numericality_of :region, :only_integer => true, :in => (1..APP_CONFIG["regions"])
  validates_numericality_of :school_code, :only_integer => true, :allow_nil => true
  validates_length_of :school_code, :minimum => 5, :allow_nil => true, :allow_blank => true
  
  fields do
    name            :string, :required
    school_code     :string
    region          :integer, :required
    address         :text
    cell_number     :string
    landline_number :string
    fax_number      :string
    email_address   :email_address
    timestamps
  end
  
  has_one :principal, :class_name => "Person"
  has_one :education_officer, :class_name => "Person"
  has_many :staff, :class_name => "Person"

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
