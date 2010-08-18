class HoboMigration30 < ActiveRecord::Migration
  def self.up
    add_column :users, :state, :string, :default => "active"
    add_column :users, :key_timestamp, :datetime

    add_index :users, [:state]
  end

  def self.down
    remove_column :users, :state
    remove_column :users, :key_timestamp
    
    remove_index :users, :name => :index_users_on_state rescue ActiveRecord::StatementInvalid
  end
end
