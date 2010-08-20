class HoboMigration38 < ActiveRecord::Migration
  def self.up
    remove_column :person_trigrams, :created_at
    remove_column :person_trigrams, :updated_at
  end

  def self.down
    add_column :person_trigrams, :created_at, :datetime
    add_column :person_trigrams, :updated_at, :datetime
  end
end
