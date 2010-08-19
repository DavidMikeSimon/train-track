# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  before_filter :require_ssl
  
  def require_ssl
    # Only redirect from port 80 so that non-Internet access isn't messed with
    if APP_CONFIG["ssl_required"] && request.port == 80 && !request.ssl?
      redirect_to "https://" + request.host + request.request_uri
      flash.keep
      return false
    end
  end
  
  before_filter :check_for_login
  
  def check_for_login
    return true if current_user.signed_up?
    redirect_to :controller => :users, :action => :login
    return
  end
end
