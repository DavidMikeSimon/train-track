class HoboMigration2 < ActiveRecord::Migration
  def self.up
    remove_column :users, :key_timestamp
    remove_column :users, :state

    remove_index :users, :name => :index_users_on_state rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :users, :key_timestamp, :datetime
    add_column :users, :state, :string, :default => "invited"

    add_index :users, [:state]
  end
end
