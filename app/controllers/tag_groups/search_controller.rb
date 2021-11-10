class TagGroups::SearchController < ApplicationController
  respond_to :html

  def current_ability
    @current_ability ||= ::TagGroupAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    authorize! :search, TagGroup

    builder = Search::ClauseBuilder.new(attributes: [], params: params)

    where_params = builder.build_clauses(params)
    order_params = builder.build_order_clauses(request.query_parameters)

    @enrollment_results = TagGroup.pagy_search(params[:q].present? ? params[:q] : "*",
                                               aggs: { tags: {} },
                                               where: where_params.merge({ discarded_at: nil }),
                                               order: order_params)
    @pagy, @results = pagy_searchkick(@enrollment_results, items: 10)
  end
end
