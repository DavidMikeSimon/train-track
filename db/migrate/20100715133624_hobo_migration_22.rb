class HoboMigration22 < ActiveRecord::Migration
  def self.up
    add_column :appointments, :attendances_count, :integer

    Appointment.reset_column_information
    Appointment.all.each do |appointment|
      Appointment.update_counters appointment.id, :attendances_count => appointment.attendances.length
    end
  end

  def self.down
    remove_column :appointments, :attendances_count
  end
end
