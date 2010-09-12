class HoboMigration40 < ActiveRecord::Migration
  def self.up
    add_column :workshop_sessions, :length, :integer, :default => 0
  end

  def self.down
    remove_column :workshop_sessions, :length
  end
end
