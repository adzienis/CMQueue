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

  def new_link
    return nil unless actions.include?(:new) && helpers.can?(:new, resource_class)

    link_to("New #{resource.to_s.titleize}", polymorphic_path([:new, parent, resource].flatten), class: "btn btn-primary")
  end
end
