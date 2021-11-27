module Shared
  class SidebarComponent < ViewComponent::Base
    renders_many :entries
    renders_one :body

    def initialize
      super
    end
  end
end
