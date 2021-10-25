class Questions::SearchController < ApplicationController
  respond_to :html

  def current_ability
    @current_ability ||= ::QuestionAbility.new(current_user,{
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def build_clause(query_key)
    begin
      parsed = JSON.parse(params[query_key])
    rescue JSON::ParserError
      parsed = params[query_key]
    end

    return {} if parsed.instance_of?(Array) && parsed.empty?

    { query_key => parsed }
  end

  def index
    authorize! :search, Question

    search_params = {}

    search_params = search_params.merge(build_clause(:state)) if params[:state]
    search_params = search_params.merge(build_clause(:user_name)) if params[:user_name]
    search_params = search_params.merge(build_clause(:tags)) if params[:tags]

    @question_results = Question.pagy_search(params[:q].present? ? params[:q] : "*",
                                             aggs: [:state, :user_name, :resolved_by, :tags],
                                             where: search_params.merge({ discarded_at: nil }))
    @pagy, @results = pagy_searchkick(@question_results, items: 10)

    respond_with @questions
  end
end
