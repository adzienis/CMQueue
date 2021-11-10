class Analytics::Metabase::Dashboards::UnarchiveDashboard
  def initialize(dashboard_id:, metabase:)
    @dashboard_id = dashboard_id
    @metabase = metabase
  end

  def call
    metabase.put_dashboard(dashboard_id: dashboard_id,
                           json: Analytics::Metabase::Dashboards::Unarchive.new(dashboard_id: dashboard_id).call)
  end

  private

  attr_reader :dashboard_id, :metabase
end