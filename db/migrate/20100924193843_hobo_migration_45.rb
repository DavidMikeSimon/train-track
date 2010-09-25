class HoboMigration45 < ActiveRecord::Migration
  def self.up
    add_column :institutions, :bep, :boolean
  end

  def self.down
    remove_column :institutions, :bep
  end
end
