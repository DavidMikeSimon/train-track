require 'csv'

task :load_schools_csv => :environment do
  Institution.transaction do
    CSV.open("#{RAILS_ROOT}/schools.csv", "r") do |row|
      schid, inst_name, region = row
      inst_name.gsub!("&", "and")
      
      institutions = Institution.all(:conditions => {:name => inst_name, :region => region.to_i})
      if institutions.size == 1
        puts "+++ Found institution %s" % [inst_name]
      elsif institutions.size > 1
        puts "EEE Too many matches for institution %s" % [inst_name]
        raise "Cancelling"
      else
        puts "EEE Unable to find institution %s" % [inst_name]
        raise "Cancelling"
      end
      
      institution = institutions.first
      institution.bep = true
      institution.school_code = schid
      institution.save!
    end
  end
end
