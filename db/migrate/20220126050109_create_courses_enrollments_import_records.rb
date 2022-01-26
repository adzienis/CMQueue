class CreateCoursesEnrollmentsImportRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_enrollments_import_records do |t|
      t.belongs_to :course, foreign_key: false, null: true
      t.string :status
      t.timestamps
    end
  end
end
