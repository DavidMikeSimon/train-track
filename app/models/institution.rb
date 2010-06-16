class Institution < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  Parish = HoboFields::EnumString.for(
    "Clarendon",
    "Hanover",
    "Kingston",
    "Manchester",
    "Portland",
    "St. Andrew",
    "St. Ann",
    "St. Catherine",
    "St. Elizabeth",
    "St. James",
    "St. Mary",
    "St. Thomas",
    "Trelawny",
    "Westmoreland"
  )
  
  OrganizationType = HoboFields::EnumString.for(:training_organization, :school)
  
  validates_numericality_of :school_code, :only_integer => true, :allow_nil => true, :allow_blank => true
  validates_length_of :school_code, :minimum => 5, :allow_nil => true, :allow_blank => true
  
  validates_numericality_of(
    :region,
    :only_integer => true,
    :allow_nil => true,
    :greater_than_or_equal_to => 1,
    :less_than_or_equal_to => APP_CONFIG["regions"]
  )
  
  fields do
    name               :string, :required
    school_code        :string
    region             :integer, :required
    address            :text
    parish             Institution::Parish
    telephone_numbers  :string
    fax_number         :string
    email_address      :email_address
    organization_type  Institution::OrganizationType, :default => "school"
    principal          :string
    education_officer  :string
    timestamps
  end
  
  index [:name, :region], :unique => true

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
