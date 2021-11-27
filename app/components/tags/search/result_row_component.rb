module Tags
  module Search
    class ResultRowComponent < ViewComponent::Base
      def initialize(tag:)
        super
        @tag = tag
      end

      def visibility_msg
        tag.archived ? "Hidden" : "Visible"
      end

      def visibility_class
        tag.archived? ? "bg-danger" : "bg-success"
      end

      private

      attr_reader :tag
    end
  end
end
