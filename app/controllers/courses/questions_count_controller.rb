class Courses::QuestionsCountController < ApplicationController
  respond_to :json

  def show
    @questions = Question.undiscarded.order(:created_at)
    @questions = @questions.with_courses(params[:course_id]) if params[:course_id]
    @questions = @questions.with_users(params[:user_id]) if params[:user_id]
    @questions = @questions.latest_by_state(JSON.parse(params[:state])) if params[:state]

    @questions = @questions.count

    respond_with @questions
  end
end
