require 'csv'

task :init_data => :environment do
  col_names = []
  Institution.transaction do
    CSV.open("#{RAILS_ROOT}/BEP_Schools250.csv", "r") do |row|
      if col_names.size == 0
        col_names = row
      else
        data = {}
        row.each_index do |idx|
          data[col_names[idx]] = row[idx]
        end
        next if data["School Name"].blank?
        
        rec = Institution.new(
          :name => data["School Name"],
          :region => data["Reg"],
          :address => data["Address 2"].blank? ? data["Address 1"] : "#{data['Address 1']}\n#{data['Address 2']}",
          :parish => data["Parish"],
          :landline_number => data["Tele #"],
          :cell_number => (data["Tele #1"] == data["Tele #"]) ? data["Tele #2"] : data["Tele #1"],
          :fax_number => data["Fax # 1"],
          :email_address => data["Email Address"]
        )
        rec.save or raise "Invalid record #{rec.inspect}"
      end
    end
  end
end
