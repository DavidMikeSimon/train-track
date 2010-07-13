class HoboMigration18 < ActiveRecord::Migration
  def self.up
    create_table :workshop_sessions do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :workshop_id
    end
    add_index :workshop_sessions, [:workshop_id]

    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_id rescue ActiveRecord::StatementInvalid
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group, :in_use, :id]
  end

  def self.down
    drop_table :workshop_sessions

    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group_id]
    add_index :random_identifiers, [:random_identifier_group_id, :in_use, :id], :name => 'index_random_identifiers_on_random_identifier_group_and_in_use_and_id'
  end
end
