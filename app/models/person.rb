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
    grade_taught    :string
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

  belongs_to :institution

  set_default_order "last_name, first_name"

  def before_save
    self.grade_taught = grade_taught.to_s.strip.upcase.split(/[, \/]+/).map{|g| g.scan(/\d+|\D+/).map{|e| e.match(/\d+/) ? e.to_i : e}}.sort.map{|g| g.join}.join(" ")
  end

  def after_update
    if first_name_changed? || last_name_changed? || job_id_changed? || job_details_changed?
      Appointment.all(:conditions => {:person_id => self.id}).each do |appt|
        appt.print_needed = true
        appt.save!
      end
    end
  end

  def after_offroad_upload
    extract_trigrams!
  end

  # This is silly, but eager loading didn't cooperate even after hours of hacking about, so this is how it'll be for now
  def self.attendees_with_report_fields
    # Preload all the relevant data (argh, can't belive I'm doing this)
    appointments = {}; Appointment.all.each { |r| appointments[r.id] = r }
    people = {}; Person.all(:include => [:institution, :job]).each { |r| people[r.id] = r }
    training_subjects = {}; TrainingSubject.all.each { |r| training_subjects[r.id] = r }
    workshop_sessions = {}; WorkshopSession.all.each { |r| workshop_sessions[r.id] = r }
    workshops = {}; Workshop.all.each { |r| workshops[r.id] = r }

    people.each do |i, p|
      p["total_minutes"] = 0
    end
    training_subjects.each do |i, ts|
      workshops.each do |j, w|
        if w.workshop_sessions.any?{|s| s.training_subject_id == ts.id}
          people.each do |i, p|
            p["w#{w.id}_attended"] = nil
            p["w#{w.id}t#{ts.id}_minutes"] = 0
          end
        end
      end
      people.each do |i, p|
        p["t#{ts.id}_minutes"] = 0
      end
    end

    # Go through each attendance and use it to fill in the report columns
    Attendance.find_each do |a|
      appt = appointments[a.appointment_id]
      workshop_session = workshop_sessions[a.workshop_session_id]
      person = people[appt.person_id]
      workshop = workshops[appt.workshop_id]
      
      # Figure out the attendance time for each workshop: the earliest attendance
      att_key = "w#{workshop.id}_attended"
      if person[att_key].nil? or person[att_key] > workshop_session.starts_at
        person[att_key] = workshop_session.starts_at
      end

      # Add up minutes from this attended session to the appropriate fields
      person["total_minutes"] += workshop_session.minutes
      person["t#{workshop_session.training_subject_id}_minutes"] += workshop_session.minutes
      person["w#{workshop.id}t#{workshop_session.training_subject_id}_minutes"] += workshop_session.minutes
    end

    # Don't bother reporting people who have no attendance information
    people.keys.each do |i|
      people.delete(i) if people[i]["total_minutes"] == 0
    end

    return people.values.sort{ |a,b| [a.institution.try.name || "", a.last_name, a.first_name] <=> [b.institution.try.name || "", b.last_name, b.first_name] }
  end
  
  named_scope :sorted_by_last_name, :order => "last_name, first_name"
  
  def name
    "#{first_name} #{last_name}"
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

  def edit_permitted?(field)
    update_permitted?
  end
  
  acts_as_offroadable :group_single
end
