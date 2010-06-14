class HoboMigration7 < ActiveRecord::Migration
  def self.up
    add_column :institutions, :parish, :string

    add_index :institutions, [:name], :unique => true
  end

  def self.down
    remove_column :institutions, :parish

    remove_index :institutions, :name => :index_institutions_on_name rescue ActiveRecord::StatementInvalid
  end
end
