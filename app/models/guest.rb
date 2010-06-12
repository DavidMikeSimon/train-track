class Guest < Hobo::Guest
  # This is a pseudo-model for an unregistered user of the app
  # It is *not* a participant for a workshop; see Person for that.
  
  def administrator?
    false
  end

end
