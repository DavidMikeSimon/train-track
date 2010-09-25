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
  
  has_many :appointments, :dependent => :destroy, :include => :workshop, :order => "workshops.first_day"
  has_many :attendances, :through => :appointments
  
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

  # FIXME Ridiculously un-Railsy hack, but can't seem to get eager loading to work on this issue
  def self.minute_count_select_expr(col_name, training_subject = nil)
    "(SELECT SUM(workshop_sessions.minutes) FROM appointments LEFT JOIN attendances ON attendances.appointment_id = appointments.id LEFT JOIN workshop_sessions ON workshop_sessions.id = attendances.workshop_session_id WHERE appointments.person_id = people.id #{training_subject ? "AND workshop_sessions.training_subject_id = %u" % training_subject.id : ""}) as #{col_name}"
  end

  # FIXME This is silly, I should be able to do this with eager-loading, but it isn't working for some reason
  named_scope :with_minute_count_fields, lambda { { :select =>
    (
      ["people.*"] + 
      TrainingSubject.all.map{|ts| minute_count_select_expr("%s_minutes" % ts.name.gsub(" ", "_").underscore, ts)} +
      [minute_count_select_expr("total_minutes")] +
      ["name", "region", "bep", "school_code"].map { |institution_field|
        "(SELECT institutions.#{institution_field} FROM appointments LEFT JOIN institutions ON institutions.id = appointments.institution_id LEFT JOIN workshops ON workshops.id = appointments.workshop_id WHERE appointments.person_id = people.id ORDER BY workshops.first_day DESC LIMIT 1) AS institution_#{institution_field}"
      }
    ).join(',')
  } }

  named_scope :sorted_by_last_name, :order => "last_name, first_name"
  
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
