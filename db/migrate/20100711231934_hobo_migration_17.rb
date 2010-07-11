class HoboMigration17 < ActiveRecord::Migration
  def self.up
    add_column :appointments, :random_identifier_id, :integer
    
    add_column :workshops, :random_identifier_id, :integer
    add_column :workshops, :appointment_identifier_group_id, :integer
    
    add_index :appointments, [:random_identifier_id]
    
    add_index :workshops, [:random_identifier_id]
    add_index :workshops, [:appointment_identifier_group_id]
    
    add_index :random_identifiers, [:random_identifier_group_id]
    add_index :random_identifiers, [:random_identifier_group, :in_use, :id]
    
    RandomIdentifierGroup.create(:name => "workshops", :max_value => TrainCode::DOMAIN-1)
    
    Workshop.reset_column_information
    Workshop.all.each do |workshop|
      workshop.random_identifier = RandomIdentifierGroup.find_by_name("workshops").grab_identifier
      workshop.appointment_identifier_group = RandomIdentifierGroup.create(:name => "appointments-%u" % workshop.id, :max_value => TrainCode::DOMAIN-1)
      workshop.save!
    end
    
    Appointment.reset_column_information
    Appointment.all.each do |appt|
      appt.random_identifier = appt.workshop.appointment_identifier_group.grab_identifier
      appt.save!
    end
  end

  def self.down
    Workshop.all.each do |workshop|
      workshop.appointment_identifier_group.destroy
    end
    
    RandomIdentifierGroup.find_by_name("workshops").destroy
    
    remove_column :appointments, :random_identifier_id
    
    remove_column :workshops, :random_identifier_id
    remove_column :workshops, :appointment_identifier_group_id
    
    remove_index :appointments, :name => :index_appointments_on_random_identifier_id rescue ActiveRecord::StatementInvalid
    
    remove_index :workshops, :name => :index_workshops_on_random_identifier_id rescue ActiveRecord::StatementInvalid
    remove_index :workshops, :name => :index_workshops_on_appointment_identifier_group_id rescue ActiveRecord::StatementInvalid
    
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_id rescue ActiveRecord::StatementInvalid
    remove_index :random_identifiers, :name => :index_random_identifiers_on_random_identifier_group_and_in_use_and_id rescue ActiveRecord::StatementInvalid
  end
end
