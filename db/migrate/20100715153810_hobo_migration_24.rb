class HoboMigration24 < ActiveRecord::Migration
  def self.up
    add_column :workshop_sessions, :starts_at, :datetime

    add_index :appointments, [:workshop_id, :person_id, :role], :unique => true
  end

  def self.down
    remove_column :workshop_sessions, :starts_at

    remove_index :appointments, :name => :index_appointments_on_workshop_id_and_person_id_and_role rescue ActiveRecord::StatementInvalid
  end
end
