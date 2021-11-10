class Analytics::Metabase::Card
  def initialize(card:, metabase:)
    @card = card
    @metabase = metabase
  end

  def id
    card["id"]
  end

  def add_to_dashboard(dashboard_id)
    Analytics::Metabase::Dashboards::AddCardToDashboard.new(metabase: metabase,
                                                            dashboard_id: dashboard_id,
                                                            card_id: id).call
  end

  private

  attr_reader :card, :metabase
end