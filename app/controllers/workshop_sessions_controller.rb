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
    @length = params[:length]
    date_parts = params[:start_date].split("-").map(&:to_i)
    @starts_at = DateTime.new(
      date_parts[0],
      date_parts[1],
      date_parts[2],
      params[:start_hour].to_i,
      params[:start_minute].to_i,
      0
    )
    @workshop_session = WorkshopSession.create(:workshop_id => @workshop_id, :starts_at => @starts_at, :length => @length, :name => @name)
    if @workshop_session then
      render :update do |page|
        page.insert_html :top, "workshop-session-container", :partial => @workshop_session
      end
    else
      render nil
    end
  end

end
