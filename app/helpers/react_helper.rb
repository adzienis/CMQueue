# frozen_string_literal: true

module ReactHelper
  def react_component_with_content(name, args = {}, options = {}, &block)
    args[:__html] = capture(&block) if block.present?
    react_component(name, args, options, &block)
  end
end
