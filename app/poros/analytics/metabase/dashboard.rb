class Analytics::Metabase::Dashboard
  def initialize(dashboard:, metabase:)
    @dashboard = dashboard
    @metabase = metabase
  end

  def id
    dashboard["id"]
  end

  def archive
    Analytics::Metabase::Dashboards::ArchiveDashboard.new(dashboard_id: id, metabase: metabase).call
  end

  def unarchive
    Analytics::Metabase::Dashboards::UnarchiveDashboard.new(dashboard_id: id, metabase: metabase).call
  end

  private

  attr_reader :dashboard, :metabase
end