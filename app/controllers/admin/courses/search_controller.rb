class Admin::CoursesController < Admin::ApplicationController
  def index
    @registrations = Course.search "*"
    builder = Search::ClauseBuilder.new(attributes: [], params: params)

    where_params = builder.build_clauses(params)
    order_params = builder.build_order_clauses(request.query_parameters)

    @results = Course.pagy_search(params[:q].present? ? params[:q] : "*",
      aggs: [:approved],
      where: where_params,
      order: order_params)
    @pagy, @results = pagy_searchkick(@results, items: 10)
  end
end
