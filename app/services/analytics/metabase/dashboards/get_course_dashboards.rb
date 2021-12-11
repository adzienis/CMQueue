class Analytics::Metabase::Dashboards::GetCourseDashboards
  include Metabaseable

  def initialize(course:)
    @course = course
  end

  def call
    collection = metabase.collections.find{|c| c.name == course.name}

    return [] if collection.nil?

    items = metabase.collection_items(collection.id)

    return [] if items.nil?

    items["data"].filter{|item| item["model"] == "dashboard"}.map{|v| Analytics::Metabase::API::Dashboard.new(dashboard: v)}
  end

  private

  attr_reader :course
end
