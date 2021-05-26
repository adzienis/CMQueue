class CreateEnrollments < ActiveRecord::Migration[6.1]
  def change
    create_table :enrollments do |t|
      t.belongs_to :course
      t.belongs_to :user
      t.timestamps
    end
    add_index :enrollments, [:course_id, :user_id], unique: true
  end
end
