class Courses::AnswerController < ApplicationController
  def show
    question_state = current_user.question_state
    @top_question = question_state&.question
  end
end
