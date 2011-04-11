class WorkshopSession < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  fields do
    name        :string, :required
    starts_at   :datetime, :required
    minutes     :integer, :required, :default => 0
    timestamps
  end
  
  index [:workshop_id, :name], :unique => true
  
  belongs_to :workshop, :index => false
  validates_presence_of :workshop
  
  belongs_to :random_identifier, :dependent => :destroy

  belongs_to :training_subject
  
  has_many :attendances, :dependent => :destroy
  has_many :appointments, :through => :attendances, :include => :person, :accessible => true, :conditions => 'workshop_id = #{workshop_id}', :order => "people.last_name, people.first_name"
  
  def before_create
    self.random_identifier = workshop.workshop_session_identifier_group.grab_identifier
    self.training_subject ||= workshop.default_training_subject
  end
  
  def train_code
    "SES-%s" % TrainCode.encode(random_identifier.identifier)
  end
  
  def description
    s = "%s, %s - %s, %s" % [self.starts_at.strftime("%B %d, %Y"), self.starts_at.strftime("%I:%M %p"), self.ends_at.strftime("%I:%M %p"), self.name]
    if self.training_subject
      s += " (%s)" % self.training_subject.name
    end
    return s
  end
  
  def to_s
    description
  end

  def ends_at
    return starts_at + (minutes*60)
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up? && only_changed?(:name, :starts_at, :minutes, :training_subject, :attendances)
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

  #acts_as_offroadable :group_owned, :parent => :workshop
end
