class HoboMigration21 < ActiveRecord::Migration
  def self.up
    add_column :workshops, :workshop_session_identifier_group_id, :integer

    add_column :workshop_sessions, :random_identifier_id, :integer

    add_index :workshops, [:workshop_session_identifier_group_id]

    add_index :workshop_sessions, [:random_identifier_id]
    
    Workshop.reset_column_information
    Workshop.all.each do |workshop|
      workshop.workshop_session_identifier_group = RandomIdentifierGroup.create(:name => "workshop-sessions-%u" % workshop.id, :max_value => TrainCode::DOMAIN-1)
      workshop.save!
    end
    
    WorkshopSession.reset_column_information
    WorkshopSession.all.each do |ses|
      ses.random_identifier = ses.workshop.workshop_session_identifier_group.grab_identifier
      ses.save!
    end
  end

  def self.down
    Workshop.all.each do |workshop|
      workshop.workshop_session_identifier_group.destroy
    end
    
    remove_column :workshops, :workshop_session_identifier_group_id

    remove_column :workshop_sessions, :random_identifier_id

    remove_index :workshops, :name => :index_workshops_on_workshop_session_identifier_group_id rescue ActiveRecord::StatementInvalid

    remove_index :workshop_sessions, :name => :index_workshop_sessions_on_random_identifier_id rescue ActiveRecord::StatementInvalid
  end
end
