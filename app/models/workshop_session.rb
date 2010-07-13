class WorkshopSession < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  fields do
    name        :string, :required
    timestamps
  end
  
  index [:workshop_id, :name], :unique => true
  
  belongs_to :workshop
  validates_presence_of :workshop
  
  has_many :attendances
  
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
