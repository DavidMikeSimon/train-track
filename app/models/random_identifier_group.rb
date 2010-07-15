class RandomIdentifierGroup < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  fields do
    name               :string, :required
    max_value          :integer, :required
  end
  
  index :name, :unique => true
  
  set_default_order "name"
  
  has_many :random_identifiers, :dependent => :destroy
  
  def after_create
    self.transaction do
      (1..max_value).sort_by{rand}.each do |i|
        self.connection.execute("INSERT INTO random_identifiers (random_identifier_group_id, identifier) VALUES(%u, %u)" % [self.id, i])
      end
    end
  end
  
  def after_destroy
    # Using delete instead of destroy because it skips RandomIdentifier's after_destroy (and also is much faster)
    RandomIdentifier.delete_all(:random_identifier_group_id => self.id)
  end
  
  def find_used_identifier(identifier)
    random_identifiers.first(:conditions => { :in_use => true, :identifier => identifier})
  end
  
  def grab_identifier
    returning random_identifiers.first(:conditions => { :in_use => false }) do |i|
      raise "Unable to find an unused random identifier in group %s" % name unless i
      i.in_use = true
      i.save!
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
