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
    order_params = builder.build_order_clauses(params)

    @question_results = Question.pagy_search(params[:q].present? ? params[:q] : "*",
                                             aggs: { state: {},
                                                     user_name: {},
                                                     resolved_by: {},
                                                     tags: {},
                                                     created_at: {
                                                       ranges: [{ from: DateTime.now.beginning_of_day,
                                                                  to: DateTime.now.end_of_day, key: 'Today' },
                                                                { from: DateTime.now.beginning_of_day - 1,
                                                                  to: DateTime.now.end_of_day - 1, key: 'Yesterday' }]
                                                     }
                                             },
                                             order: order_params,
                                             where: where_params.merge({ discarded_at: nil }))
    @pagy, @results = pagy_searchkick(@question_results, items: 10)
  end
end
