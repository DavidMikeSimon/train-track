class AppointmentsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :workshop, [:new, :create]

end
