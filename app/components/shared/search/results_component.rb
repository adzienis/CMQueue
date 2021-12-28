module Shared
  module Search
    class ResultsComponent < ViewComponent::Base
      renders_many :results

      def initialize(parent:, pagy:, search:, options: {})
        super
        @parent = parent
        @pagy = pagy
        @search = search
        @options = options
      end

      def resources
        search.klass.name.demodulize.pluralize.underscore.to_sym
      end

      def resource
        search.klass.name.demodulize.underscore.to_sym
      end

      def msg
        if pagy.count == 1
          "#{pagy.count} #{resource.to_s.titleize} in #{search.took} ms"
        else
          "#{pagy.count} #{resources.to_s.titleize} in #{search.took} ms"
        end
      end

      def headers
        options[:headers] || []
      end

      private

      attr_reader :search, :parent, :pagy, :options
    end
  end
end
