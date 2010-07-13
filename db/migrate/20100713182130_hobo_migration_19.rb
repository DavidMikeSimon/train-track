class HoboMigration19 < ActiveRecord::Migration
  def self.up
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_id rescue ActiveRecord::StatementInvalid
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group, :in_use, :id]

    add_index :workshop_sessions, [:workshop_id, :name], :unique => true
  end

  def self.down
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group_id]
    add_index :random_identifiers, [:random_identifier_group_id, :in_use, :id], :name => 'index_random_identifiers_on_random_identifier_group_and_in_use_and_id'

    remove_index :workshop_sessions, :name => :index_workshop_sessions_on_workshop_id_and_name rescue ActiveRecord::StatementInvalid
  end
end
