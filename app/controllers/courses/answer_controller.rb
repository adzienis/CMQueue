class Courses::AnswerController < ApplicationController

  before_action :authorize

  def authorize
    authorize! :answer, @course
  end

  def show
    question_state = current_user.question_state
    @top_question = question_state&.question
  end
end
