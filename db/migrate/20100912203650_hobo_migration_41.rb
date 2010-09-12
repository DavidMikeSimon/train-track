class HoboMigration41 < ActiveRecord::Migration
  def self.up
    rename_column :workshop_sessions, :length, :minutes
  end

  def self.down
    rename_column :workshop_sessions, :minutes, :length
  end
end
