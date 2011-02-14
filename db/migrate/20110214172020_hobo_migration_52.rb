class HoboMigration52 < ActiveRecord::Migration
  def self.up
    change_column :institutions, :region, :integer, :default => nil
  end

  def self.down
    change_column :institutions, :region, :integer
  end
end
