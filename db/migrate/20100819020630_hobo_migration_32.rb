class HoboMigration32 < ActiveRecord::Migration
  def self.up
    add_column :institutions, :female_teachers_total, :integer, :default => 0
    add_column :institutions, :male_teachers_total, :integer, :default => 0
    add_column :institutions, :female_teachers_early_grade_total, :integer, :default => 0
    add_column :institutions, :male_teachers_early_grade_total, :integer, :default => 0
  end

  def self.down
    remove_column :institutions, :female_teachers_total
    remove_column :institutions, :male_teachers_total
    remove_column :institutions, :female_teachers_early_grade_total
    remove_column :institutions, :male_teachers_early_grade_total
  end
end
