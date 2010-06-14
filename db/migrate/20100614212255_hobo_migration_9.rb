class HoboMigration9 < ActiveRecord::Migration
  def self.up
    remove_index :institutions, :name => :index_institutions_on_name rescue ActiveRecord::StatementInvalid
    add_index :institutions, [:name, :region], :unique => true
  end

  def self.down
    remove_index :institutions, :name => :index_institutions_on_name_and_region rescue ActiveRecord::StatementInvalid
    add_index :institutions, [:name], :unique => true
  end
end
