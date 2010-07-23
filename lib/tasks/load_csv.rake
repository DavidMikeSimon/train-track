require 'csv'

task :load_csv => :environment do
  Workshop.transaction do
    workshop = Workshop.last or raise "No workshop available to insert into"
    
    [["InputAttendees.csv", :participant, "school"], ["InputPresenters.csv", :trainer, "training_organization"]].each do |filename, role, organization_type|
      puts ""
      puts "###################"
      puts filename
      puts "###################"
      puts ""
      puts ""
      puts ""
      
      CSV.open("#{RAILS_ROOT}/#{filename}", "r") do |row|
        inst_name, person_name, gender, person_role = row
        name_parts = person_name.split(" ")
        last_name = name_parts.pop
        first_name = name_parts.join(" ")
        
        gender = gender.downcase
        if gender == "m"
          gender = "male"
        else
          gender = "female"
        end
        
        institution = Institution.find_by_name_and_organization_type(
          inst_name,
          organization_type
        )
        if institution
          puts "+++ Found institution %s" % [inst_name]
        else
          puts "EEE Unable to find institution %s" % [inst_name]
        end
        
        person = Person.find_or_initialize_by_first_name_and_last_name_and_gender(
          first_name,
          last_name,
          gender,
          :title => gender == "female" ? "Ms." : "Mr.",
          :role => person_role
        )
        if person.valid?
          person.role = person_role
          person.save!
          puts "+++ Person %s %s (NEW:%s)" % [first_name, last_name, person.new_record?]
        else
          puts "EEE Unable to create person: #{person.inspect}"
        end
        
        if institution && person.valid?
          appt = Appointment.new(
            :role => role,
            :workshop => workshop,
            :person => person,
            :institution => institution
          )
          appt.save!
          puts "+++ Appointment"
        end

        puts ""
      end
    end
  end
end
