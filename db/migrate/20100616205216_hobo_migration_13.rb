class HoboMigration13 < ActiveRecord::Migration
  def self.up
    remove_index :appointments, :name => :index_appointments_on_workshop_id_and_person_id rescue ActiveRecord::StatementInvalid
    add_index :appointments, [:workshop_id, :person_id, :role], :unique => true
  end

  def self.down
    remove_index :appointments, :name => :index_appointments_on_workshop_id_and_person_id_and_role rescue ActiveRecord::StatementInvalid
    add_index :appointments, [:workshop_id, :person_id], :unique => true
  end
end
