class HoboMigration15 < ActiveRecord::Migration
  def self.up
    add_column :random_identifier_groups, :max_value, :integer

    add_index :random_identifiers, [:random_identifier_group, :in_use, :id]
  end

  def self.down
    remove_column :random_identifier_groups, :max_value

    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
  end
end
