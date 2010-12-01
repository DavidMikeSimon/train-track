class HoboMigration49 < ActiveRecord::Migration
  def self.up
    create_table :institution_trigrams do |t|
      t.string  :token, :null => false
      t.integer :institution_id
    end
    add_index :institution_trigrams, [:token]
    add_index :institution_trigrams, [:institution_id]

    InstitutionTrigram.reset_column_information
    Institution.all.each do |i|
      i.extract_trigrams!
    end
  end

  def self.down
    drop_table :institution_trigrams
  end
end
