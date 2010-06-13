class HoboMigration5 < ActiveRecord::Migration
  def self.up
    rename_column :workshops, :beginning, :first_day
    rename_column :workshops, :ending, :last_day
    change_column :workshops, :first_day, :date
    change_column :workshops, :last_day, :date
  end

  def self.down
    rename_column :workshops, :first_day, :beginning
    rename_column :workshops, :last_day, :ending
    change_column :workshops, :beginning, :datetime
    change_column :workshops, :ending, :datetime
  end
end
