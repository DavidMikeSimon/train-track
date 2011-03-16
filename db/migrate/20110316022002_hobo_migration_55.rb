class HoboMigration55 < ActiveRecord::Migration
  def self.up
    RandomIdentifier.delete_all(:in_use => false)

    remove_column :random_identifiers, :in_use
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_id_and_in_u rescue ActiveRecord::StatementInvalid
    add_index :random_identifiers, [:random_identifier_group_id]
  end

  def self.down
    # Well, it actually is reversible I suppose, but I can't imagine needing to reverse it, so no reason to bother
    # coding this up.
    raise ActiveRecord::IrreversibleMigration
  end
end
