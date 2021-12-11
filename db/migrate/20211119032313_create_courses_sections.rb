class CreateCoursesSections < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_sections do |t|
      t.belongs_to :course
      t.string :name
      t.timestamps
    end

    create_table :courses_sections_enrollments, id: false do |t|
      t.belongs_to :courses_section
      t.belongs_to :enrollment
    end
  end
end
