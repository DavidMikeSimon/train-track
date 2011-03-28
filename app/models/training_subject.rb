class TrainingSubject < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
    name  :string, :required
    timestamps
  end
   
  has_many :workshops, :foreign_key => :default_training_subject, :dependent => :nullify
  has_many :workshop_sessions, :dependent => :nullify

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

  acts_as_offroadable :group_single
end
