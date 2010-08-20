class HoboMigration37 < ActiveRecord::Migration
  def self.up
    create_table :person_trigrams do |t|
      t.string   :token, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :person_id
    end
    add_index :person_trigrams, [:person_id]
  end

  def self.down
    drop_table :person_trigrams
  end
end
