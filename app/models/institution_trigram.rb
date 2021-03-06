class InstitutionTrigram < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
    token :string, :null => false
  end
  
  index :token
  
  belongs_to :institution

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

  def edit_permitted?(field)
    update_permitted?
  end
end
