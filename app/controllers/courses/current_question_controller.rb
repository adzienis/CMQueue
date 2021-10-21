class Courses::CurrentQuestionController < ApplicationController
  respond_to :json

  def show
    question = current_user.questions.with_courses(@course).latest_by_state(["unresolved", "resolving", "frozen"]).undiscarded.first

    respond_with question.as_json include: [:question_state]
  end
end
