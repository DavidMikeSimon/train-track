class InstitutionsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def index
    permission_denied("Permission Denied") unless current_user.administrator?
    hobo_index
  end
end
