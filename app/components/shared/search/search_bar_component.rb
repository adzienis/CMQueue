class Shared::Search::SearchBarComponent < ViewComponent::Base
  def initialize(resources:, course:, query_parameters:)
    @resources = resources
    @course = course
    @query_parameters = query_parameters
  end

  private

  attr_reader :resources, :course, :query_parameters
end
