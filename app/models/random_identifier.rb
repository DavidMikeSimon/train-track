class RandomIdentifier < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
    identifier              :integer, :required
  end
  
  belongs_to :random_identifier_group
  validates_presence_of :random_identifier_group
  
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
    acting_user.administrator?
  end

  def edit_permitted?(field)
    update_permitted?
  end

  acts_as_offroadable :group_single
end
