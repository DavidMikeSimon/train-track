class HoboMigration42 < ActiveRecord::Migration
  def self.up
    create_table :training_subjects do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    TrainingSubject.create!(:name => "Literacy")
    TrainingSubject.create!(:name => "Numeracy")
    TrainingSubject.create!(:name => "Leadership")
  end

  def self.down
    drop_table :training_subjects
  end
end
