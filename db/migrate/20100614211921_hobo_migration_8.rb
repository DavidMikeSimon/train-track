class HoboMigration8 < ActiveRecord::Migration
  def self.up
    rename_column :institutions, :landline_number, :telephone_numbers
    remove_column :institutions, :cell_number
  end

  def self.down
    rename_column :institutions, :telephone_numbers, :landline_number
    add_column :institutions, :cell_number, :string
  end
end
