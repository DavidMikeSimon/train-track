class HoboMigration50 < ActiveRecord::Migration
  def self.up
    change_column :people, :grade_taught, :string, :limit => 255
  end

  def self.down
    change_column :people, :grade_taught, :integer
  end
end
