class Analytics::Metabase::Dashboards::UnarchiveDashboard
  def initialize(dashboard_id:)
    @dashboard_id = dashboard_id
  end

  def call
    metabase.put_dashboard(dashboard_id: dashboard_id,
      json: json)
  end

  private

  def json
    {
      archived: false
    }
  end

  attr_reader :dashboard_id
end
