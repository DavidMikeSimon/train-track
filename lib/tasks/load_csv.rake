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
        inst_name, first_name, last_name, gender, region = row
        if region
          region = region.to_i
        else
          puts "!!! [%s, %s, %s] Unknown region, defaulting to 1" % [inst_name, first_name, last_name]
          region = 1
        end
        
        gender = gender.downcase
        if gender == "m"
          gender = :male
        else
          gender = :female
        end
        
        institution = Institution.find_by_name_and_region_and_organization_type(
          inst_name,
          region,
          organization_type
        )
        if institution
          puts "+++ Found institution %u %s" % [region, inst_name]
        else
          puts "EEE Unable to find institution %u %s" % [region, inst_name]
        end
        
        person = Person.new(
          :first_name => first_name,
          :last_name => last_name,
          :gender => gender,
          :title => gender == :female ? "Ms." : "Mr."
        )
        if person.valid?
          person.save!
          puts "+++ Person %s %s" % [first_name, last_name]
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
