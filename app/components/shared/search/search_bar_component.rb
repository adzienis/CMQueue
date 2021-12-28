class Shared::Search::SearchBarComponent < ViewComponent::Base
  def initialize(resources:, parent:, query_parameters:, options: {})
    @resources = resources
    @parent = parent
    @query_parameters = query_parameters
    @options = options
  end

  def actions
    @actions ||= options[:actions] || {}
  end

  def resource_class
    @resource_class ||= resource.to_s.classify.constantize
  end

  def resource
    @resource ||= resources.to_s.singularize.to_sym
  end

  private

  attr_reader :resources, :parent, :query_parameters, :options
end
