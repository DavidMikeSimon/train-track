class InstitutionsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def index
    hobo_index Institution.fuzzy_find_scope(params[:search])
  end
end
