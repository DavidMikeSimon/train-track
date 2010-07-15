class WorkshopSession < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  fields do
    name        :string, :required
    attendances_count :integer, :default => 0
    timestamps
  end
  
  index [:workshop_id, :name], :unique => true
  
  belongs_to :workshop
  validates_presence_of :workshop
  
  belongs_to :random_identifier, :dependent => :destroy
  
  has_many :attendances
  
  def train_code
    "SES-%s" % TrainCode.encode(random_identifier.identifier)
  end
  
  def before_create
    self.random_identifier = workshop.workshop_session_identifier_group.grab_identifier
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up? && only_changed?(:name)
  end

  def destroy_permitted?
    acting_user.signed_up?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
