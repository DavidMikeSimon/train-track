class HoboMigration6 < ActiveRecord::Migration
  def self.up
    add_column :appointments, :role, :string
  end

  def self.down
    remove_column :appointments, :role
  end
end
