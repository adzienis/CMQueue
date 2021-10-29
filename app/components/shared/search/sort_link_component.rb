class Shared::Search::SortLinkComponent < ViewComponent::Base
  def initialize(category:, query_params:, course:, resources:)
    @category = category
    @query_params = query_params
    @course = course
    @resources = resources
  end

  def html_class
    selected? ? "fw-bold" : ""
  end

  def selected?
    return false unless query_params[:sort].present?

    split = query_params[:sort].split('_')

    attribute = split[..-2].join("_")

    attribute == category.to_s
  end

  def direction
    return @direction if defined?(@direction)

    return @direction = :desc unless query_params[:sort]

    split = query_params[:sort].split('_')

    attribute = split[..-2].join("_")
    order = split[-1]
    if attribute == category.to_s
      return @direction = :asc if order == "desc"
    end

    @direction = :desc
  end

  def merged_query_params
    return query_params.merge(sort: "#{category}_asc") if direction == :asc

    query_params.merge(sort: "#{category}_desc")
  end

  private

  attr_reader :category, :query_params, :course, :resources
end
