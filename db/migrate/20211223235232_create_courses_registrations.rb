class CreateCoursesRegistrations < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_registrations do |t|
      t.text :name, null: false
      t.boolean :approved, default: false
      t.bigint :instructor_id, null: false

      t.timestamps
    end
  end
end
