class UsersController < ApplicationController
  
  hobo_user_controller

  auto_actions :login, :logout, :update, :account
  
  skip_filter :check_for_login, :only => [:login]

end
