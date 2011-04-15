class ConvertAdHocQec < ActiveRecord::Migration
  def self.up
    Institution.all.each do |i|
      if i.address =~ /^(.+)QEC\W{0,10}(\d+\w*)\s*$/im
        i.address = $1.strip
        i.qec = $2
        i.save!
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
