class HoboMigration29 < ActiveRecord::Migration
  def self.up
    add_column :people, :role, :string
  end

  def self.down
    remove_column :people, :role
  end
end
