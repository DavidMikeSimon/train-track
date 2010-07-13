class HoboMigration20 < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :appointment_id
      t.integer  :workshop_session_id
    end
    add_index :attendances, [:appointment_id]
    add_index :attendances, [:workshop_session_id]
    add_index :attendances, [:workshop_session_id, :appointment_id], :unique => true
  end

  def self.down
    drop_table :attendances
  end
end
