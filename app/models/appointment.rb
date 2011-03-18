class Appointment < ActiveRecord::Base
  hobo_model # Don't put anything above this

  Role = HoboFields::EnumString.for(:participant, :presenter)
  
  fields do
    print_needed :boolean, :default => true
    registered   :boolean, :default => false
    role         Appointment::Role, :required
    timestamps
  end
  
  validates_presence_of :workshop, :person
  
  belongs_to :workshop, :index => false # Index would duplicate the multi-column index below
  acts_as_offroadable :group_owned, :parent => :workshop
  
  belongs_to :person
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

  def to_s
    # FIXME - This is specific to the workshop session edit page, it belongs in that view
    "%s from %s" % [person.name, person.institution.try.medium_name.to_s]
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
