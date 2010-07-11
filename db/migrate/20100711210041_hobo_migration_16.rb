class HoboMigration16 < ActiveRecord::Migration
  def self.up
    rename_column :random_identifiers, :identifer, :identifier

    add_index :random_identifiers, [:random_identifier_group, :in_use, :id]
  end

  def self.down
    rename_column :random_identifiers, :identifier, :identifer

    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
  end
end
