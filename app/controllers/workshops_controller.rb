require 'csv'

class WorkshopsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  show_action :csv_codes do
    headers['Content-Disposition'] = "attachment; filename=\"participants.csv\""
    headers['Content-Type'] = 'text/csv'
    
    workshop = Workshop.find(params[:id])
    render :text => proc { |response, output|
      workshop.participant_appointments.find_in_batches(:include => [:person, :random_identifier]) do |batch|
        batch.each do |appointment|
          output.write "\"%s\",\"%s\"\n" % [appointment.person, appointment.train_code]
        end
      end
    }
  end

end
