require 'csv'
require 'parsedate'

task :load_prior_data_csv => :environment do
  Institution.transaction do
    CSV.open("#{RAILS_ROOT}/importing.csv", "r") do |row|
      region, school_id, inst_name, skip, first_name, last_name,\
        gender, job_string, skip, sens_date, skip, skip, emai_date, skip, skip, \
        erai_date, skip, skip, pc_date, skip, skip = row
      inst_name.gsub!("&", "and") 

      inst_name.strip!
      first_name.strip!
      last_name.strip!
      job_string.strip!

      workshops = {}
      {
        :sens => "Regional Office Sensitization",
        :erai => "ERAI Training",
        :emai => "EMAI Training",
        :pc => "Principals/Chairpersons Workshop"
      }.each do |key, value|
        workshops[key] = Workshop.find_by_title(value) or raise "Couldn't find workshop '#{value}'"
      end

      jobs = Job.all

      inst = nil
      if school_id != ""
        inst = Institution.first(:conditions => {:school_code => school_id})
        unless inst
          raise "EEE Couldn't find institution with school code #{school_id}"
        end
      else
        inst = Institution.first(:conditions => {:name => inst_name})
        unless inst
          raise "EEE Couldn't find institution named #{inst_name}"
        end
      end

      person = Person.fuzzy_find("#{first_name} #{last_name}")[0]
      if person.nil? || person.fuzzy_weight < 80
        job = nil
        jobs.each do |j|
          if job_string.include?(j.name) && (job.nil? || j.name.length > job.name.length)
            job = j
          end
        end

        person = Person.create!(
          :first_name => first_name,
          :last_name => last_name,
          :gender => (gender == "M" ? :male : :female),
          :title => (gender == "M" ? "Mr." : "Ms."),
          :job => job,
          :job_details => job ? job_string.gsub(job.name, "").strip : job_string
        ) 
      end

      workshops.each do |k, workshop|
        date_str = case k
          when :sens then sens_date
          when :erai then erai_date
          when :emai then emai_date
          when :pc then pc_date
          else raise "Unknown workshop key value #{k}"
        end
        next if date_str.to_s == ""

        date = ParseDate.parsedate(date_str, true)
        t = DateTime.new(date[0], date[1], date[2], 12)
        sess = WorkshopSession.find_or_create_by_workshop_id_and_starts_at(:workshop_id => workshop.id, :name => "Training Session #{date[0]}-#{date[1]}-#{date[2]}", :starts_at => t, :minutes => 180)
        raise "Couldn't create session, #{sess.inspect}" if sess.new_record?
        puts "APPT: workshop #{workshop}, person #{person.name}"
        appt = Appointment.create!(:workshop => workshop, :person => person, :institution => inst, :role => "participant")
        Attendance.create!(:appointment => appt, :workshop_session => sess)
      end
    end
  end
end
