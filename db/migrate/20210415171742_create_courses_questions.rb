class CreateCoursesQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_questions, id:false do |t|
      t.belongs_to :course
      t.belongs_to :question
    end

  end
end
