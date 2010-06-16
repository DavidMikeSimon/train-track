class HoboMigration12 < ActiveRecord::Migration
  def self.up
    add_index :people, [:first_name, :last_name, :institution_id], :unique => true
  end

  def self.down
    remove_index :people, :name => :index_people_on_first_name_and_last_name_and_institution_id rescue ActiveRecord::StatementInvalid
  end
end
