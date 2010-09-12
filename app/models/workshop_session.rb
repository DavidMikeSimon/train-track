class WorkshopSession < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  fields do
    name        :string, :required
    starts_at   :datetime, :required
    length      :integer, :required, :default => 0
    timestamps
  end
  
  index [:workshop_id, :name], :unique => true
  
  belongs_to :workshop
  validates_presence_of :workshop
  
  belongs_to :random_identifier, :dependent => :destroy
  
  has_many :attendances, :dependent => :destroy
  has_many :appointments, :through => :attendances, :include => [:person, :institution], :accessible => true, :conditions => 'workshop_id = #{workshop_id}', :order => "people.last_name, people.first_name"
  
  def train_code
    "SES-%s" % TrainCode.encode(random_identifier.identifier)
  end
  
  def before_create
    self.random_identifier = workshop.workshop_session_identifier_group.grab_identifier
  end
  
  def description
    "%s (%u minutes) - %s" % [self.starts_at.to_formatted_s(:long_ordinal), self.length, self.name]
  end
  
  def to_s
    description
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up? && only_changed?(:name, :starts_at, :attendances)
  end

  def destroy_permitted?
    acting_user.signed_up?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
