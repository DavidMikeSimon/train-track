class HoboMigration28 < ActiveRecord::Migration
  def self.up
    add_column :appointments, :print_needed, :boolean, :default => true
    
    Appointment.reset_column_information
    Appointment.all.each do |appt|
      appt.print_needed = false
      appt.save!
    end
  end
  
  def self.down
    remove_column :appointments, :print_needed
  end
end
