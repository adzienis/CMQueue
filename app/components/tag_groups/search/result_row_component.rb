module TagGroups
  module Search
    class ResultRowComponent < ViewComponent::Base
      def initialize(tag_group:)
        super
        @tag_group = tag_group
      end

      private

      attr_reader :tag_group
    end
  end
end
