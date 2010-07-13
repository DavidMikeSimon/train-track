class RandomIdentifier < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  fields do
    identifier              :integer, :required
    in_use                  :boolean, :default => false
  end
  
  belongs_to :random_identifier_group, :index => false # Index would duplicate the multi-column index below
  
  validates_presence_of :random_identifier_group
  index [:random_identifier_group, :in_use, :id]
  
  def after_destroy
    # Like a zombie rising from the grave, discarded in_use RandomIdentifiers come back to life as not in_use
    if in_use?
      RandomIdentifier.create(
        :random_identifier_group_id => random_identifier_group_id,
        :identifier => identifier,
        :in_use => false
      )
    end
  end
  
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

end
