class Guest < Hobo::Guest
  # This is a pseudo-model for an unregistered user of the app
  # It is *not* a participant for a workshop; see Person for that.
  
  def administrator?
    false
  end

  def signed_up?
    # If we're offline and there's a workshop, consider guests as normal users
    Offroad::app_offline? && !Workshop.empty_offline?
  end
end
