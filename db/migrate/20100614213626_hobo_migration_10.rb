class HoboMigration10 < ActiveRecord::Migration
  def self.up
    add_column :institutions, :organization_type, :string, :default => "school"
  end

  def self.down
    remove_column :institutions, :organization_type
  end
end
