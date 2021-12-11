module Analytics
  module Metabase
    class DashboardFrameComponent < ViewComponent::Base
      def initialize(dashboard_id:)
        super
        @dashboard_id = dashboard_id
      end

      def url
        @url ||= Rails.configuration.general[:external_analytics_url]
      end

      def secret_key
        @secret_key ||= ENV["MB_EMBEDDING_SECRET_KEY"]
      end

      def payload
        @payload ||= {
          :resource => { dashboard: dashboard_id.to_i },
          :params => {
          },
          :exp => Time.now.to_i + (60 * 100) # 10 minute expiration
        }
      end

      def token
        @token ||= JWT.encode(payload, secret_key)
      end

      def iframe_url
        @iframe_url ||= "#{url}/embed/dashboard/#{token}#bordered=true&titled=true"
      end

      private

      attr_reader :dashboard_id
    end
  end
end
