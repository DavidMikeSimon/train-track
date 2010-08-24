class PeopleController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:new, :create]
  
  def index
	hobo_index Person.fuzzy_find_scope(params[:search])
  end

end
