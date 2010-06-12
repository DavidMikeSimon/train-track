class HoboMigration3 < ActiveRecord::Migration
  def self.up
    create_table :workshops do |t|
      t.string   :title
      t.datetime :date
      t.string   :venue
      t.integer  :region
      t.string   :purpose
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :people do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :title
      t.string   :gender
      t.string   :cell_number
      t.string   :landline_number
      t.string   :fax_number
      t.string   :email_address
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :institution_id
    end
    add_index :people, [:institution_id]

    create_table :institutions do |t|
      t.string   :name
      t.string   :school_code
      t.integer  :region
      t.text     :address
      t.string   :cell_number
      t.string   :landline_number
      t.string   :fax_number
      t.string   :email_address
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :workshops
    drop_table :people
    drop_table :institutions
  end
end
