class HoboMigration43 < ActiveRecord::Migration
  def self.up
    add_column :workshops, :default_training_subject_id, :integer

    add_column :workshop_sessions, :training_subject_id, :integer
  end

  def self.down
    remove_column :workshops, :default_training_subject_id

    remove_column :workshop_sessions, :training_subject_id
  end
end
