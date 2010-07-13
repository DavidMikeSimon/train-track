class WorkshopSessionsController < ApplicationController

  hobo_model_controller

  auto_actions :edit
  
  def update
    hobo_update do
      redirect_to @workshop_session.workshop
    end
  end
  
  def destroy
    hobo_destroy do
      redirect_to @workshop_session.workshop
    end
  end
  
  def create
    @workshop_id = params[:workshop_id]
    @name = params[:name]
    
    @workshop_session = WorkshopSession.create(:workshop_id => @workshop_id, :name => @name)
    if @workshop_session then
      render :update do |page|
        page.insert_html :top, "workshop-session-container", :partial => @workshop_session
      end
    else
      render nil
    end
  end

end
