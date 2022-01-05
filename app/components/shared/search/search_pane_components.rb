class Shared::Search::SearchPaneComponents < ViewComponent::Base
  def initialize(results:, query_params:, resources:, resource_path:, options: {})
    @results = results
    @query_params = query_params
    @resources = resources
    @options = options
    @resource_path = resource_path
  end

  def agg_keys
    return @agg_keys if defined?(@agg_keys)
    @agg_keys = results.aggs.filter { |k, v| v["buckets"].count > 0 }.keys || []
    @agg_keys += options[:extra_aggs] if options[:extra_aggs]
    @agg_keys
  end

  def render?
    results.aggs&.present?
  end

  def sort_link(category)
    if query_params[:sort]
      split = query_params[:sort].split("_")

      attribute = split[..-2].join("_")
      order = split[-1]

      if attribute == category.to_s
        if order == "desc"
          link_to "Sort by #{category}",
            polymorphic_path(resource_path,
              query_params.merge(sort: "#{category}_asc")),
            "data-turbo-frame": "_self"
        else
          link_to "Sort by #{category}",
            polymorphic_path(resource_path,
              query_params.merge(sort: "#{category}_desc")),
            "data-turbo-frame": "_self"

        end
      else
        link_to "Sort by #{category}",
          polymorphic_path(resource_path,
            query_params.merge(sort: "#{category}_desc")),
          "data-turbo-frame": "_self"
      end
    else
      link_to "Sort by #{category}",
        polymorphic_path(resource_path,
          query_params.merge(sort: "#{category}_desc")),
        "data-turbo-frame": "_self"
    end
  end

  private

  attr_reader :results, :query_params, :resources, :options, :resource_path
end
