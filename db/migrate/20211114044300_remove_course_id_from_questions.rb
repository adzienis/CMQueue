class RemoveCourseIdFromQuestions < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions, :course_id, :reference
  end
end
