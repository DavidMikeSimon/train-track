class HoboMigration51 < ActiveRecord::Migration
  def self.up
    add_column :people, :institution_id, :integer
    add_index :people, [:institution_id]

    Person.reset_column_information

    Person.attendees_with_report_fields.each do |p|
      p.institution = p["institution"]
      p.save!
    end
  end

  def self.down
    remove_column :people, :institution_id
    remove_index :people, :name => :index_people_on_institution_id rescue ActiveRecord::StatementInvalid
  end
end
