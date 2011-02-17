class HoboMigration53 < ActiveRecord::Migration
  def self.up
    remove_column :appointments, :institution_id
  end

  def self.down
    add_column :appointments, :institution_id, :integer
  end
end
