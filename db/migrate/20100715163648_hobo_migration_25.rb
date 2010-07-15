class HoboMigration25 < ActiveRecord::Migration
  def self.up
    create_table :processed_xml_files do |t|
      t.string   :filename
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :processed_xml_files
  end
end
