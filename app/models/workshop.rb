class Workshop < ActiveRecord::Base
  hobo_model # Don't put anything above this

  validates_numericality_of(
    :region,
    :only_integer => true,
    :allow_nil => true,
    :greater_than_or_equal_to => 1,
    :less_than_or_equal_to => APP_CONFIG["regions"]
  )
  
  fields do
    title     :string, :required
    first_day :date, :required
    last_day  :date, :required
    venue     :string
    region    :integer
    purpose   :string
    timestamps
  end

  set_default_order "first_day DESC"
  
  # The identifier for the workshop itself, from the "workshops" RandomIdentifierGroup
  belongs_to :random_identifier, :dependent => :destroy
  
  # Identifier groups for our appointments and sessions
  belongs_to :appointment_identifier_group, :class_name => "RandomIdentifierGroup", :dependent => :destroy
  belongs_to :workshop_session_identifier_group, :class_name => "RandomIdentifierGroup", :dependent => :destroy

  # Default TrainingSubject for new sessions in this workshop
  belongs_to :default_training_subject, :class_name => "TrainingSubject"
  
  has_many :workshop_sessions, :dependent => :destroy, :order => "starts_at, name"
  
  has_many :appointments, :dependent => :destroy, :include => [:person, :random_identifier, :attendances]
  has_many :people, :through => :appointments
  
  has_many(
    :participant_appointments,
    :class_name => "Appointment",
    :conditions => { :role => "participant" },
    :include => [:person, :random_identifier, :attendances]
  )
  has_many :participants, :through => :participant_appointments, :source => :person
  
  has_many(
    :presenter_appointments,
    :class_name => "Appointment",
    :conditions => { :role => "presenter" },
    :include => [:person, :random_identifier, :attendances]
  )
  has_many :presenters, :through => :presenter_appointments, :source => :person
  
  attr_protected :random_identifier, :appointment_identifier_group, :workshop_session_identifier_group
  
  def after_create
    self.random_identifier = RandomIdentifierGroup.find_by_name("workshops").grab_identifier
    self.appointment_identifier_group = RandomIdentifierGroup.create(:name => "appointments-%u" % self.id, :max_value => TrainCode::DOMAIN-1)
    self.workshop_session_identifier_group = RandomIdentifierGroup.create(:name => "workshop-sessions-%u" % self.id, :max_value => TrainCode::DOMAIN-1)
    save!
  end
  
  def train_code
    "WKS-%s" % TrainCode.encode(random_identifier.identifier)
  end

  def set_offline
    self.group_offline = true
  end

  def force_online
    self.group_offline = false
  end
  
  # --- Permissions --- #
  
  def create_permitted?
    acting_user.signed_up? || Workshop.empty_offline?
  end
  
  def update_permitted?
    acting_user.signed_up?
  end
  
  def destroy_permitted?
    acting_user.administrator? && Offroad.app_online?
  end
  
  def view_permitted?(field)
    acting_user.signed_up?
  end

  def edit_permitted?(field)
    update_permitted?
  end

  def set_offline_permitted?
    Offroad::app_online? && Workshop.offline_groups.size == 0 && update_permitted?
  end

  def force_online_permitted?
    Offroad::app_online? && group_offline? && acting_user.signed_up?
  end

  def upload_mirror_file_permitted?
    group_offline? && acting_user.signed_up?
  end

  def self.empty_offline?
    Offroad::app_offline? && (Workshop.first == nil || Workshop.first.locked_by_offroad?)
  end

  acts_as_offroadable :group_base
end
