class Institution < ActiveRecord::Base
  hobo_model # Don't put anything above this

  Parish = HoboFields::EnumString.for(
    "N/A",
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
    region             :integer
    address            :text
    parish             Institution::Parish
    telephone_numbers  :string
    fax_number         :string
    email_address      :email_address
    organization_type  Institution::OrganizationType, :default => "school"
    principal          :string
    education_officer  :string
    bep                :boolean, :default => false
    female_students_total    :integer, :default => 0
    male_students_total      :integer, :default => 0
    female_students_early_grade_total :integer, :default => 0
    male_students_early_grade_total :integer, :default => 0
    female_teachers_total    :integer, :default => 0
    male_teachers_total      :integer, :default => 0
    female_teachers_early_grade_total :integer, :default => 0
    male_teachers_early_grade_total :integer, :default => 0
    timestamps
  end
  
  include FuzzySearch
  fuzzy_search_attributes :name

  index [:name, :region], :unique => true

  has_many :people, :dependent => :nullify
  
  set_default_order "name"
  
  def medium_name
    region ? "#{name} (R#{region})" : name
  end

  def to_s
    medium_name
  end
  
  def long_name
    (region && parish != "N/A") ? "#{name}, #{parish}, Region #{region}" : name
  end
  
  def before_save
    if name_changed?
      self.name = self.class.clean_name(self.name)
    end
  end

  def after_update
    if name_changed? || region_changed?
      people.all do |person|
        person.appointments.each do |appt|
          appt.print_needed = true
          appt.save!
        end
      end
    end
  end
  
  def after_offroad_upload
    extract_trigrams!
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
    
    s.gsub!(/\b&/, " &")
    s.gsub!(/&\b/, "& ")
    s.gsub!("&", "and")
    s.gsub!("Infant.", "Infant") #Sometimes it's abbreviated "Inf."
    
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
    acting_user.signed_up?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

  def edit_permitted?(field)
    update_permitted?
  end

  acts_as_offroadable :group_single
end
