class Questions::SearchController < ApplicationController
  respond_to :html

  def index
    search_params = {}
    search_params = search_params.merge(state: params[:state]) if params[:state]
    search_params = search_params.merge(user_name: params[:user_name]) if params[:user_name]
    search_params = search_params.merge(tags: [params[:tags]]) if params[:tags]

    @question_results = Question.pagy_search(params[:q].present? ? params[:q] : "*",
                                             aggs: [:state, :user_name, :resolved_by, :tags],
                                             where: search_params.merge({discarded_at: nil}))
    @pagy, @results = pagy_searchkick(@question_results, items: 10)

    respond_with @questions
  end
end
