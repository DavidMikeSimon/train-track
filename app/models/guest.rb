class Guest < Hobo::Guest
  # This is a pseudo-model for an unregistered user of the app
  # It is *not* a participant for a workshop; see Person for that.
  
  # FIXME - Temporarily granting all privileges to Guest for demo purposes
  
  def administrator?
    true
  end
  
  def signed_up?
    true
  end

end
