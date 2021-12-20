class Courses::FeedController < ApplicationController
  respond_to :html, :json

  before_action do
    authorize! :answer, @course
  end

  def index
    @current_enrollment.selected_tags = params[:tags]
  end

  def answer
    builder = Search::ClauseBuilder.new(attributes: [:tags], params: feed_params)

    where_params = builder.build_clauses(params,
      extra_params: {
        course_id: @course.id,
        state: ["unresolved"],
        discarded_at: nil
      })

    @question_results = Question.search(params[:q].present? ? params[:q] : "*",
      aggs: {tags: {}},
      includes: [:user, :tags, :question_states],
      order: {created_at: {order: :asc, unmapped_type: :date}},
      where: where_params,
      limit: 1)
    @questions = @question_results.results
    question = @question_results.results.first

    update_state = ::Questions::UpdateState.new(question: question,
      enrollment: @current_enrollment,
      state: "resolving",
      description: "",
      options: {update_creator?: true})
    update_state.call

    if update_state.error.present?
      flash[:error] = update_state.error.message
      return redirect_back(fallback_location: queue_course_path(@course))
    end

    redirect_to answer_course_path(@course)
  end

  private

  def feed_params
    params.permit(tags: [])
  end
end
