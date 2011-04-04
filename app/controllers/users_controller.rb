class UsersController < ApplicationController

  before_filter :require_online
  def require_online
    redirect_to(:controller => :workshops) unless Offroad::app_online?
  end
  
  hobo_user_controller

  auto_actions :login, :logout, :update, :account
  
  skip_filter :check_for_login, :only => [:login]

end
