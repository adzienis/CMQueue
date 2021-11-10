class Analytics::Metabase::Dashboards::AddCardToDashboard
  def initialize(metabase:, dashboard_id:, card_id:)
    @card_id = card_id
    @metabase = metabase
    @dashboard_id = dashboard_id
  end

  def call
    metabase.post_dashboard_cards(dashboard_id: dashboard_id,
                                  json: Analytics::Metabase::Dashboards::AddCard.new(card_id: card_id).call)
  end

  private

  attr_reader :metabase, :card_id, :dashboard_id
end