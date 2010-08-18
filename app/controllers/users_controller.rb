class UsersController < ApplicationController
  
  hobo_user_controller

  auto_actions :all, :except => :signup
  
  skip_filter :check_for_login, :only => [:login, :forgot_password, :reset_password]

end
