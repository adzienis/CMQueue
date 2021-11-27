module Shared
  class SidebarEntryComponent < ViewComponent::Base
    renders_one :icon

    def initialize(name:, path:)
      super
      @name = name
      @path = path
    end

    def entry_controller_path
      Rails.application.routes.recognize_path(path)[:controller]
    end

    private

    attr_reader :name, :path
  end
end
