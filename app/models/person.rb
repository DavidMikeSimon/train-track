class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  Title = HoboFields::EnumString.for("Ms.", "Mrs.", "Miss", "Mr.", "Dr.", "Rev.", "Sister", "Fr.", "Prof.")
  Gender = HoboFields::EnumString.for(:female, :male)
  
  fields do
    first_name      :string, :required
    last_name       :string, :required
    title           Person::Title, :required
    gender          Person::Gender, :required
    cell_number     :string
    landline_number :string
    fax_number      :string
    email_address   :email_address
    grade_taught    :integer # TODO Maybe should use serialize and make this "grades_taught"? Does Hobo work with that?
    job_details     :string
    timestamps
  end
  
  def validate
    if ["Ms.", "Mrs.", "Miss", "Sister"].include?(title) && gender == :male
      errors.add_to_base "You cannot use the title \"#{title}\" for a male person."
    elsif ["Mr.", "Fr."].include?(title) && gender == :female
      errors.add_to_base "You cannot use the title \"#{title}\" for a female person."
    end
  end
  
  include FuzzySearch
  fuzzy_search_attributes :first_name, :last_name
  
  belongs_to :job
  
  has_many :appointments, :dependent => :destroy
  
  set_default_order "last_name, first_name"
  
  def after_update
    # TODO : If title or department ends up on appointment card, check that here too 
    if first_name_changed? || last_name_changed? || job_id_changed? || job_details_changed?
      Appointment.all(:conditions => {:person_id => self.id}).each do |appt|
        appt.print_needed = true
        appt.save!
      end
    end
  end
  
  def last_institution
    # TODO Implement; find the institution of the most recent appointment
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
  
  def name
    "#{first_name} #{last_name}"
  end

end
