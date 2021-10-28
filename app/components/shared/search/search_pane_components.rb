class Shared::Search::SearchPaneComponents < ViewComponent::Base
  def initialize(results:, course:, query_params:, resources:, options: {})
    @results = results
    @course = course
    @query_params = query_params
    @resources = resources
    @options = options
  end

  def agg_keys
    @agg_keys = results.aggs&.keys || []
    @agg_keys += options[:extra_aggs] if options[:extra_aggs]
    @agg_keys
  end

  def sort_link(category)
    if query_params[:sort]
      split = query_params[:sort].split('_')

      attribute = split[..-2].join("_")
      order = split[-1]

      if attribute == category.to_s
        if order == "desc"
          link_to "Sort by #{category}",
                  polymorphic_path([:search, course, resources],
                                   query_params.merge(sort: "#{category}_asc"))
        else
          link_to "Sort by #{category}",
                  polymorphic_path([:search, course, resources],
                                   query_params.merge(sort: "#{category}_desc"))
        end
      else
        link_to "Sort by #{category}",
                polymorphic_path([:search, course, resources],
                                 query_params.merge(sort: "#{category}_desc"))
      end
    else
      link_to "Sort by #{category}",
              polymorphic_path([:search, course, resources],
                               query_params.merge(sort: "#{category}_desc"))
    end
  end

  private

  attr_reader :results, :course, :query_params, :resources, :options
end