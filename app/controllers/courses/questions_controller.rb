class Courses::QuestionsController < ApplicationController
  respond_to :html

  def edit
    @question = Question.find(params[:question_id])
  end

  def show
    @question = Question.find(params[:question_id])
  end

  def update
    @question = Question.find(params[:question_id])
    @question.update(question_params)

    if question_state_params.present? && question_state_params[:state] != @question.question_state.state
      @question.unsafely_create_question_state(question_state_params
                                                 .merge({ enrollment_id: current_user.enrollment_in_course(@course).id }))
    end
    @question.update!(updated_at: Time.current)

    respond_with @question, location: search_course_questions_path(@question.course)
  end

  private

  def question_params
    params.require(:question).permit(:course_id,
                                     :description,
                                     :tried,
                                     :location,
                                     :user_id,
                                     :title,
                                     :enrollment_id,
                                     :notes,
                                     tag_ids: [])

  end

  def question_state_params
    params.require(:question).require(:question_state_attributes).permit(:state)
  end
end
