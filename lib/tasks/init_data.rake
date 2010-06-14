require 'csv'

def tel_numbers_string(*numbers)
  results = []
  numbers.each do |number|
    next if number == nil
    number.strip!
    next if ["", "-"].include?(number)
    results << number unless results.include?(number)
  end
  return results.join(", ")
end

task :init_data => :environment do
  col_names = []
  Institution.transaction do
    Institution.create(
      :name => "Basic Education Project",
      :parish => "Kingston",
      :region => 1,
      :organization_type => :training_organization
    )
    
    CSV.open("#{RAILS_ROOT}/BEP_Schools250.csv", "r") do |row|
      if col_names.size == 0
        col_names = row
      else
        data = {}
        row.each_index do |idx|
          data[col_names[idx]] = row[idx] ? row[idx].strip : ""
        end
        next if data["School Name"].blank?
        
        rec = Institution.new(
          :name => data["School Name"],
          :region => data["Reg"],
          :address => data["Address 2"].blank? ? data["Address 1"] : "#{data['Address 1']}\n#{data['Address 2']}",
          :parish => data["Parish"],
          :telephone_numbers => tel_numbers_string(data["Tele #"], data["Tele #1"], data["Tele #2"], data["Tele #3"]),
          :fax_number => tel_numbers_string(data["Fax # 1"])
        )
        rec.parish = rec.parish.sub(/^St.([^ ])/, 'St. \1') # Replace i.e. "St.James" with "St. James"
        rec.valid? or raise "Invalid record #{rec.inspect}"
        rec.save or raise "Unable to save record #{rec.inspect}"
      end
    end
  end
end
