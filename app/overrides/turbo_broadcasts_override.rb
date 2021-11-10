#
# We override here because of the way we render ViewComponent entities.
# When we call ApplicationController.render(instance_of_view_component), it correctly makes it html_safe.
# But, when sidekiq serializes the html string, it is not html_safe anymore, therefore causing it to
# escape the tags when the ApplicationController renders it again in render_format.
#
Turbo::Streams::Broadcasts.module_eval do
  def broadcast_action_to(*streamables, action:, target: nil, targets: nil, **rendering)
    safe_rendering = rendering.map{|k,v| v.respond_to?(:html_safe) ? [k,v.html_safe] : [k,v]}.to_h

    broadcast_stream_to(*streamables,
                        content: turbo_stream_action_tag(action,
                                                         target: target,
                                                         targets: targets,
                                                         template:  rendering.delete(:content) || (rendering.any? ? render_format(:html, **safe_rendering) : nil)
    ))
  end
end