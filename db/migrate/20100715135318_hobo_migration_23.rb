class HoboMigration23 < ActiveRecord::Migration
  def self.up
    change_column :appointments, :attendances_count, :integer, :default => 0

    add_column :workshop_sessions, :attendances_count, :integer, :default => 0
    
    WorkshopSession.reset_column_information
    WorkshopSession.all.each do |workshop_session|
      WorkshopSession.update_counters workshop_session.id, :attendances_count => workshop_session.attendances.length
    end
  end

  def self.down
    change_column :appointments, :attendances_count, :integer

    remove_column :workshop_sessions, :attendances_count
  end
end
