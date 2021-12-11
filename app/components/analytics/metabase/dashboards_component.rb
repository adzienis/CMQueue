module Analytics
  module Metabase
    class DashboardsComponent < ViewComponent::Base
      def initialize(course:)
        @course = course
      end

      def dashboards
        @dashboards ||= Analytics::Metabase::Dashboards::GetCourseDashboards.new(course: @course)
                                                                            .call
                                                                            .filter{|d| d.enable_embedding }
      end

      private

      attr_reader :course
    end
  end
end
