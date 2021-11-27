class Courses::FeedController < ApplicationController
  respond_to :html, :json

  def index
    @pagy, @results = Search::FeedSearch.new(params: params, course: @course).search

    @questions = @results.results
  end

  def answer
    builder = Search::ClauseBuilder.new(attributes: [:tags], params: params)

    where_params = builder.build_clauses(params,
                                         extra_params: {
                                           course_id: @course.id,
                                           state: ["unresolved"],
                                         })

    @question_results = Question.search(params[:q].present? ? params[:q] : "*",
                                        aggs: { tags: {} },
                                        includes: [:user, :tags, :question_states],
                                        order: { created_at: { order: :asc, unmapped_type: :date }},
                                                 where: where_params.merge({ discarded_at: nil, course_id: @course.id }),
                                                 limit: 1
    )
    @questions = @question_results.results
    question = @question_results.results.first
    if (error = question.resolving(enrollment_id: current_user.enrollment_in_course(@course).id))
      flash[:error]  = error.message
      redirect_to queue_course_path(@course) and return
    end

    redirect_to answer_course_path(@course)
  end
end
