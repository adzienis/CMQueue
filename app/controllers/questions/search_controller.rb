class Questions::SearchController < ApplicationController
  respond_to :html

  def current_ability
    @current_ability ||= ::QuestionAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    authorize! :search, Question

    builder = Search::ClauseBuilder.new(attributes: [:state, :user_name, :tags, :created_at], params: params)

    where_params = builder.build_clauses(params)
    where_params = where_params.merge(semester: @current_semester) unless @current_semester == "all"
    order_params = builder.build_order_clauses(params)

    @question_results = Question.pagy_search(params[:q].present? ? params[:q] : "*",
      fields: [:user_name, :description, :location, :tried],
      aggs: {state: {},
             user_name: {},
             resolved_by: {},
             tags: {},
             created_at: {
               date_ranges: [{from: DateTime.current.beginning_of_day,
                              to: DateTime.current.end_of_day, key: "Today"},
                 {from: DateTime.current.beginning_of_day - 1,
                  to: DateTime.current.end_of_day - 1, key: "Yesterday"},
                 {from: DateTime.current.beginning_of_day - 7,
                  to: DateTime.current.end_of_day, key: "Past Week"}]
             }},
      order: order_params,
      match: :text_start,
      where: where_params.merge({discarded_at: nil, course_id: @course.id}))
    @pagy, @results = pagy_searchkick(@question_results, items: 10)
  end
end
