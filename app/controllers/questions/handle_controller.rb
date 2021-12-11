class Questions::HandleController < ApplicationController
  respond_to :json, :html

  before_action :set_resource, only: :create
  before_action :authorize

  def authorize
    authorize! :create_handle, @question
  end

  def set_resource
    @question = Question.find(params[:question_id])
  end

  def create
    @question = Question.find(params[:question_id])

    update_state = ::Questions::UpdateState.new(question: @question,
      enrollment: current_user.enrollment_in_course(@question.course),
      state: params[:state],
      description: params[:description],
      options: {update_creator?: true})
    update_state.call

    if update_state.error.present?
      flash[:error] = update_state.error.message
      return redirect_back(fallback_location: queue_course_path(@question.course))
    end

    redirect_to queue_course_path(@question.course)
  end
end
