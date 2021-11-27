module Users
  module Settings
    class DesktopNotificationComponent < ViewComponent::Base
      def initialize(setting:, record:, options: {})
        super
        @setting = setting
        @record = record
        @options = options
      end

      def path
        options.fetch(:path, helpers.polymorphic_path([record, setting]))
      end

      private

      attr_reader :setting, :record, :options
    end
  end
end
