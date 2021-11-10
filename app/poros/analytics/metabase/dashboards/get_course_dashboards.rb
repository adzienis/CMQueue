class Analytics::Metabase::Dashboards::GetCourseDashboards

  def initialize(metabase:, course:)
    @metabase = metabase
    @course = course
  end

  def call
    collection = metabase.collections.find{|c| c.name == course.name}

    return [] if collection.nil?

    items = metabase.collection_items(collection.id)

    return [] if items.nil?

    items["data"].filter{|item| item["model"] == "dashboard"}
  end

  private

  attr_reader :metabase, :course

end