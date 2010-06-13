class HoboMigration4 < ActiveRecord::Migration
  def self.up
    create_table :appointments do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :workshop_id
      t.integer  :person_id
    end
    add_index :appointments, [:person_id]
    add_index :appointments, [:workshop_id, :person_id], :unique => true

    rename_column :workshops, :date, :beginning
    add_column :workshops, :ending, :datetime
  end

  def self.down
    rename_column :workshops, :beginning, :date
    remove_column :workshops, :ending

    drop_table :appointments
  end
end
