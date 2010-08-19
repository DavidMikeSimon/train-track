class HoboMigration31 < ActiveRecord::Migration
  def self.up
    add_column :institutions, :female_students_total, :integer, :default => 0
    add_column :institutions, :male_students_total, :integer, :default => 0
    add_column :institutions, :female_students_early_grade_total, :integer, :default => 0
    add_column :institutions, :male_students_early_grade_total, :integer, :default => 0
  end

  def self.down
    remove_column :institutions, :female_students_total
    remove_column :institutions, :male_students_total
    remove_column :institutions, :female_students_early_grade_total
    remove_column :institutions, :male_students_early_grade_total
  end
end
