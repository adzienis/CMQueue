class RenderComponentJob < ApplicationJob
  queue_as :default

  def perform(component_name, *streamables, opts:{}, component_args:{})
    component_class = component_name.constantize

    rendered_component = ApplicationController.render(component_class.new(**component_args), layout: false)

    SyncedTurboChannel.broadcast_replace_later_to *streamables, html: rendered_component, **opts
  end
end
