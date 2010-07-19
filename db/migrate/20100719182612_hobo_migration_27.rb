class HoboMigration27 < ActiveRecord::Migration
  def self.up
    remove_column :appointments, :attendances_count

    remove_column :workshop_sessions, :attendances_count
  end

  def self.down
    add_column :appointments, :attendances_count, :integer, :default => 0

    add_column :workshop_sessions, :attendances_count, :integer, :default => 0
  end
end
