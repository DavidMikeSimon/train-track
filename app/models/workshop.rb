class Workshop < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  validates_numericality_of :region, :only_integer => true, :in => 1..APP_CONFIG["regions"]
  
  fields do
    title     :string, :required
    date      :datetime, :required
    venue     :string, :required
    region    :integer, :required
    purpose   :string
    timestamps
  end
  
  has_many :trainers, :class_name => "Person"
  has_many :participants, :class_name => "Person"

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
