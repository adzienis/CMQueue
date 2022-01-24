module HasMetabaseEntities
  include Metabaseable

  def base_collection
    metabase.collections.find { |v| v.name == name }
  end

  def base_dashboard
    base_collection.dashboards.find{ |v| v.name == "Main" }
  end

  def mb_dashboards
    Analytics::Metabase::Dashboards::GetCourseDashboards.new(course: self).call
  end

  def custom_schema
    "course_#{id}"
  end

  def mb_schema
    "course_#{id}"
  end
end
