class ProcessedXmlFilesController < ApplicationController

  hobo_model_controller

  auto_actions :read_only

  def index
    hobo_index :order => "created_at DESC, filename", :conditions => { :accepted => false }
  end

end
