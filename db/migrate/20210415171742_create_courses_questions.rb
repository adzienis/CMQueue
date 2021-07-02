# frozen_string_literal: true

class CreateCoursesQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_questions, id: false do |t|
      t.belongs_to :course, foreign_key: true
      t.belongs_to :question, foreign_key: true
    end
  end
end
