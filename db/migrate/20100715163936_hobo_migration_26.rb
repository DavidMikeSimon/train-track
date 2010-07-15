class HoboMigration26 < ActiveRecord::Migration
  def self.up
    add_column :processed_xml_files, :accepted, :boolean
    add_column :processed_xml_files, :duplicate_entry, :boolean
  end

  def self.down
    remove_column :processed_xml_files, :accepted
    remove_column :processed_xml_files, :duplicate_entry
  end
end
