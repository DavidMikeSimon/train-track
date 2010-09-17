class ConvertConfRegistrations < ActiveRecord::Migration
  def self.up
    Workshop.all.each do |wks|
      reg_ses = wks.workshop_sessions.find_by_name("Conference Registration")
      if reg_ses
        reg_ses.appointments.all.each do |appt|
          appt.reload
          appt.registered = true
          appt.save!
        end
        reg_ses.destroy
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
