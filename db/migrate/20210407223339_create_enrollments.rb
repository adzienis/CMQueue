class CreateEnrollments < ActiveRecord::Migration[6.1]
  def change
    create_table :enrollments do |t|
      t.timestamps
      t.belongs_to :course, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :role
    end

    add_index :enrollments, [:course_id, :user_id], unique: true
  end
end
