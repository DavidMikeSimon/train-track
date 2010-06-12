class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this

  fields do
    name          :string, :required, :unique
    email_address :email_address, :login => true
    administrator :boolean, :default => false
    timestamps
  end

  # This gives admin rights to the first sign-up.
  # Just remove it if you don't want that
  before_create { |user| user.administrator = true if !Rails.env.test? && count == 0 }
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end
  
  def update_permitted?
    acting_user.administrator? || 
      (acting_user == self && only_changed?(:email_address, :crypted_password,
                                            :current_password, :password, :password_confirmation))
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.administrator? || acting_user == self
  end

end
