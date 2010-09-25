class HoboMigration46 < ActiveRecord::Migration
  def self.up
    change_column :institutions, :bep, :boolean, :default => false
  end

  def self.down
    change_column :institutions, :bep, :boolean
  end
end
