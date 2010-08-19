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
    female_students_total    :integer, :default => 0
    male_students_total      :integer, :default => 0
    female_students_early_grade_total :integer, :default => 0
    male_students_early_grade_total :integer, :default => 0
    timestamps
  end
  
  index [:name, :region], :unique => true
  
  set_default_order "name"
  
  def medium_name
    "#{name} (R#{region})"
  end
  
  def long_name
    "#{name}, #{parish}, Region #{region}"
  end
  
  def before_save
    if name_changed?
      self.name = self.class.clean_name(self.name)
    end
  end

  def after_update
    if name_changed? || region_changed?
      Appointment.all(:conditions => {:institution_id => self.id}).each do |appt|
        appt.print_needed = true
        appt.save!
      end
    end
  end
  
  NAME_ABBREVIATIONS = {
    "PJH" => "Primary and Junior High",
    "P/JH" => "Primary and Junior High",
    "AA" => "All Age",
    "A/A" => "All Age",
    "JH" => "Junior High",
    "JHS" => "Junior High",
    "HS" => "High School",
    "Inf" => "Infant",
    "P" => "Primary",
  }
  
  def self.clean_name(s)
    NAME_ABBREVIATIONS.each_pair do |short, long|
      s.gsub!(/\b(#{short})\b/, long)
    end
    
    s.gsub!(".", "")
    s.gsub!(/\b&/, " &")
    s.gsub!(/&\b/, "& ")
    s.gsub!("&", "and")
    
    s.gsub!(/ {2,}/, " ")
    s.strip!
    
    return s
  end

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
