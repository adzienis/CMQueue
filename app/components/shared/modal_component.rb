module Shared
  class ModalComponent < ViewComponent::Base
    renders_one :button
    renders_one :body
    renders_one :footer
    renders_one :title

    def initialize(id:)
      @id = id
    end

    private

    attr_reader :id
  end
end
