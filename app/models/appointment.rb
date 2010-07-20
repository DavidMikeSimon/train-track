class Appointment < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  Role = HoboFields::EnumString.for(:participant, :trainer)
  
  fields do
    print_needed :boolean, :default => true
    role         Appointment::Role, :required
    timestamps
  end
  
  validates_presence_of :workshop, :person, :institution
  
  belongs_to :workshop, :index => false # Index would duplicate the multi-column index below
  belongs_to :person
  belongs_to :institution
  belongs_to :random_identifier, :dependent => :destroy
  
  has_many :attendances, :dependent => :destroy
  has_many :workshop_sessions, :through => :attendances, :accessible => true, :conditions => 'workshop_id = #{workshop_id}'
  
  index [:workshop_id, :person_id, :role], :unique => true
  
  def train_code
    TrainCode.encode(random_identifier.identifier)
  end
  
  def before_create
    self.random_identifier = workshop.appointment_identifier_group.grab_identifier
  end

  def before_update
    self.print_needed = true if institution_changed?
  end

  def to_s
    # FIXME - This is specific to the workshop session edit page, it belongs in that view
    "%s from %s (R%u) [Added: %s]" % [person.name, institution.name, institution.region, created_at]
  end

  def non_registration_attendances_count(conf_registration_session)
    x = attendances.size
    if conf_registration_session && attendances.any?{|a| a.workshop_session_id == conf_registration_session.id}
      x -= 1
    end
    return x
  end

  def self.possible_institutions(role)
    org_type = case role
      when "participant" then "school"
      when "trainer" then "training_organization"
      else raise "Invalid role"
    end
    return Institution.find(:all, :conditions => {:organization_type => org_type}, :order => :name)
  end
  
  def self.find_or_update_or_create_by_ids(workshop_id, person_id, institution_id, role)
    appointment = Appointment.find(:first, :conditions => {
       :workshop_id => workshop_id,
       :person_id => person_id,
       :role => role
      }
    )
    
    if appointment
      if appointment.institution_id != institution_id
        appointment.institution_id = institution_id
        appointment.save!
      end
      return appointment
    else
      appt = Appointment.new(
        :workshop_id => workshop_id,
        :person_id => person_id,
        :institution_id => institution_id,
        :role => role
      )
      raise "Unable to create appointment" unless appt.valid?
      appt.save!
      return appt
    end
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

end
