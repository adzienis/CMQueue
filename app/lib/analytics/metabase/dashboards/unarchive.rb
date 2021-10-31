class Analytics::Metabase::Dashboards::Archive
  def initialize(dashboard_id:)
    @dashboard_id = dashboard_id
  end

  def call
    {
      archived: true
    }
  end

  private

  attr_reader :dashboard_id

end