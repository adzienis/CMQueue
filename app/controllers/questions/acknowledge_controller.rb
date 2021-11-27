class Questions::AcknowledgeController < ApplicationController
  def update
    @question = Question.find(params[:question_id])
    @question.question_state.update(acknowledged_at: DateTime.now)

    redirect_to new_course_forms_question_path(@question.course)
  end
end
