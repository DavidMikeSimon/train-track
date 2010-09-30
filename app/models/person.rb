require 'set'

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
  has_many :attendances, :through => :appointments
  
  set_default_order "last_name, first_name"
  
  def after_update
    if first_name_changed? || last_name_changed? || job_id_changed? || job_details_changed?
      Appointment.all(:conditions => {:person_id => self.id}).each do |appt|
        appt.print_needed = true
        appt.save!
      end
    end
  end

  def institution
    appointments.all.sort{|a,b| a.workshop.first_day <=> b.workshop.first_day}.last.try.institution
  end

  def first_session_attended(ts, workshop)
    attended_workshop_sessions_for(ts, workshop).sort{|a,b| a.starts_at <=> b.starts_at}.first
  end

  def hours_attended(ts = nil, workshop = nil)
    session_ids = Set.new(attended_workshop_sessions_for(ts, workshop).map{|s| s.id})
    minutes = attendances.select{|a| session_ids.include?(a.workshop_session_id)}.inject(0){|sum, a| sum + a.workshop_session.minutes} || 0
    return minutes/60.0
    return 0
  end

  def attended_workshop_sessions_for(ts = nil, workshop = nil)
    appts = appointments.all
    if workshop
      appts = appts.select{|a| a.workshop_id == workshop.id}
    end
    sessions = appts.map{|a| a.workshop_sessions}.flatten
    if ts
      sessions = sessions.select{|s| s.training_subject_id == ts.id}
    end
    return sessions
  end
  
  named_scope :sorted_by_last_name, :order => "last_name, first_name"
  named_scope :including_all_associations, :include => [:job, {:appointments => [:institution, :attendances, {:workshop => :workshop_sessions}]}]
  
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
