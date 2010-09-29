class HoboMigration47 < ActiveRecord::Migration
  def self.up
    Appointment.update_all("role = 'presenter'", "role = 'trainer'")
  end

  def self.down
    Appointment.update_all("role = 'trainer'", "role = 'presenter'")
  end
end
