class HoboMigration39 < ActiveRecord::Migration
  def self.up
    add_index :person_trigrams, [:token]
  end

  def self.down
    remove_index :person_trigrams, :name => :index_person_trigrams_on_token rescue ActiveRecord::StatementInvalid
  end
end
