class RenderComponentJob < ApplicationJob
  queue_as :default

  def perform(component_name, component_args)
    component_class = component_name.constantize
    # Do something later
  end
end
