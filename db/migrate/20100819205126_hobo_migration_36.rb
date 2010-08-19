class HoboMigration36 < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    rename_column :people, :role, :job_details
    add_column :people, :job_id, :integer

    add_index :people, [:job_id]
  end

  def self.down
    rename_column :people, :job_details, :role
    remove_column :people, :job_id

    drop_table :jobs

    remove_index :people, :name => :index_people_on_job_id rescue ActiveRecord::StatementInvalid
  end
end
