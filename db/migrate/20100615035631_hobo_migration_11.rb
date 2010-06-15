class HoboMigration11 < ActiveRecord::Migration
  def self.up
    add_column :appointments, :institution_id, :integer

    add_column :institutions, :principal, :string
    add_column :institutions, :education_officer, :string

    add_index :appointments, [:institution_id]
  end

  def self.down
    remove_column :appointments, :institution_id

    remove_column :institutions, :principal
    remove_column :institutions, :education_officer

    remove_index :appointments, :name => :index_appointments_on_institution_id rescue ActiveRecord::StatementInvalid
  end
end
