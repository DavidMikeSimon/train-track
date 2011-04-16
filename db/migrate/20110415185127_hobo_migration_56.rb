class HoboMigration56 < ActiveRecord::Migration
  def self.up
    add_column :institutions, :qec, :string
  end

  def self.down
    remove_column :institutions, :qec
  end
end
