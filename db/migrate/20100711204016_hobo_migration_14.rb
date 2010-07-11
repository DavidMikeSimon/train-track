class HoboMigration14 < ActiveRecord::Migration
  def self.up
    create_table :random_identifier_groups do |t|
      t.string :name
    end
    add_index :random_identifier_groups, [:name], :unique => true

    create_table :random_identifiers do |t|
      t.integer :identifer
      t.boolean :in_use, :default => false
      t.integer :random_identifier_group_id
    end
    add_index :random_identifiers, [:random_identifier_group_id]
    add_index :random_identifiers, [:random_identifier_group, :in_use, :id]

    remove_column :people, :institution_id

    remove_index :people, :name => :index_people_on_first_name_and_last_name_and_institution_id rescue ActiveRecord::StatementInvalid
    remove_index :people, :name => :index_people_on_institution_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :people, :institution_id, :integer

    drop_table :random_identifier_groups
    drop_table :random_identifiers

    add_index :people, [:first_name, :last_name, :institution_id], :unique => true
    add_index :people, [:institution_id]
  end
end
