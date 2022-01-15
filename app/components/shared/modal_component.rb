module Shared
  class ModalComponent < ViewComponent::Base
    renders_one :button
    renders_one :body
    renders_one :footer
    renders_one :title

    def initialize(id:, options: {})
      @id = id
      @options = options
    end

    private

    attr_reader :id
  end
end
