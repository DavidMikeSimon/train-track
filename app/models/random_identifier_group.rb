class RandomIdentifierGroup < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
    name               :string, :required
    max_value          :integer, :required
  end
  
  index :name, :unique => true
  
  set_default_order "name"
  
  has_many :random_identifiers, :dependent => :destroy
  
  def find_used_identifier(identifier)
    random_identifiers.first(:conditions => { :identifier => identifier}) or (
      raise "Unable to resolve identifier %s in group %s" % [identifier, name]
    )
  end
  
  def grab_identifier
    used = random_identifiers.all.map{|r| r.identifier}
    possible = (1..max_value).to_a - used
    raise "No available random identifiers left in group" if possible.size == 0
    return random_identifiers.create!(:identifier => possible[rand(possible.size)])
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

  def edit_permitted?(field)
    update_permitted?
  end

  #acts_as_offroadable :group_single
end
