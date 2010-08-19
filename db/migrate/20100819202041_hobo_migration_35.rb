class HoboMigration35 < ActiveRecord::Migration
  def self.up
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group_id, :in_use]
  end

  def self.down
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_id_and_in_use rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group_id, :in_use, :id], :name => 'index_random_identifiers_on_random_identifier_group_and_in_use_and_id'
  end
end
