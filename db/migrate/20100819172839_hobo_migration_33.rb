class HoboMigration33 < ActiveRecord::Migration
  def self.up
    add_column :people, :grade_taught, :integer
  end

  def self.down
    remove_column :people, :grade_taught
  end
end
