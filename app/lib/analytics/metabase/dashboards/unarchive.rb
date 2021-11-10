class Analytics::Metabase::Dashboards::Unarchive
  def initialize(dashboard_id:)
    @dashboard_id = dashboard_id
  end

  def call
    {
      archived: false
    }
  end

  private

  attr_reader :dashboard_id

end