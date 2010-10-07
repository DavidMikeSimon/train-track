class HoboMigration48 < ActiveRecord::Migration
  def self.up
    add_column :jobs, :admin, :boolean, :default => false
  end

  def self.down
    remove_column :jobs, :admin
  end
end
