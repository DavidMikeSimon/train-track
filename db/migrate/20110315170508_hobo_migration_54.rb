class HoboMigration54 < ActiveRecord::Migration
  def self.up
    remove_index :attendances, :name => :index_attendances_on_workshop_session_id
    remove_index :workshop_sessions, :name => :index_workshop_sessions_on_workshop_id
  end

  def self.down
    add_index :attendances, [:workshop_session_id]
    add_index :workshop_sessions, [:workshop_id]
  end
end
