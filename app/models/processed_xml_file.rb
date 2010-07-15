class ProcessedXmlFile < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    filename :string, :required
    accepted :boolean, :required
    duplicate_entry :boolean, :required
    timestamps
  end
  
  
  # --- Permissions --- #
  
  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end
