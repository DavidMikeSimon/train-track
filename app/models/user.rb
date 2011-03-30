class User < ActiveRecord::Base
  # This model represents a user of the app.
  # It does *not* represent a participant at a workshop. See Person for that.

  hobo_user_model # Don't put anything above this

  fields do
    name          :string, :required, :unique, :login => true
    email_address :email_address
    administrator :boolean, :default => false
    timestamps
  end

  # This gives admin rights to the first sign-up.
  # Just remove it if you don't want that
  before_create { |user| user.administrator = true if !Rails.env.test? && count == 0 }
  
  lifecycle do
    state :active, :default => true

    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]

  end
  
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

  acts_as_offroadable :group_single
end
