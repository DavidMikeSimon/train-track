class ProcessedXmlFile < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
    filename :string, :required
    accepted :boolean
    duplicate_entry :boolean
    timestamps
  end
  
  # --- Permissions --- #
  
  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

  def edit_permitted?(field)
    update_permitted?
  end

end
