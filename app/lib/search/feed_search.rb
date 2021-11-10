require 'pagy/extras/searchkick'

module Search
  class FeedSearch
    include Pagy::Backend

    def initialize(params:, course:)
      @params = params
      @course = course
    end

    def search
      builder = Search::ClauseBuilder.new(attributes: [:tags], params: params)

      where_params = builder.build_clauses(params,
                                           extra_params: {
                                             course_id: course.id,
                                             state: ["unresolved", "frozen"],
                                           })

      pagy_results = Question.pagy_search(params[:q].present? ? params[:q] : "*",
                                               aggs: { tags: {} },
                                               order: { created_at: :asc },
                                               where: where_params.merge({ discarded_at: nil }))
       pagy_searchkick(pagy_results, items: 10)
    end

    private

    attr_reader :params, :course

  end
end