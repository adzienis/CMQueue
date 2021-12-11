require 'pagy/extras/searchkick'

module Search
  class FeedSearch
    include Pagy::Backend

    def initialize(params:, course:)
      @params = params
      @course = course
    end

    def search
      return [@pagy, @search] if defined?(@pagy) && defined?(@search)
      @pagy, @search = search_action
    end

    private

    def search_action
      builder = Search::ClauseBuilder.new(attributes: [:tags], params: params)

      where_params = builder.build_clauses(params,
                                           extra_params: {
                                             course_id: course.id,
                                             state: ["unresolved", "frozen"],
                                           })

      pagy_results = Question.pagy_search(params[:q].present? ? params[:q] : "*",
                                          aggs: { tags: {} },
                                          order: { created_at: { order: :asc, unmapped_type: :date }},
                                          includes: [:user, :tags],
                                          where: where_params.merge({ discarded_at: nil, course_id: course.id }))
      pagy_searchkick(pagy_results, items: 10)
    end

    attr_reader :params, :course

  end
end
