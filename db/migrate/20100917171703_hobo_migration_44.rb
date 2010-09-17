class HoboMigration44 < ActiveRecord::Migration
  def self.up
    add_column :appointments, :registered, :boolean, :default => false
  end

  def self.down
    remove_column :appointments, :registered
  end
end
