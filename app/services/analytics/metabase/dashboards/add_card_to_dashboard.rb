class Analytics::Metabase::Dashboards::AddCardToDashboard
  include Metabaseable

  def initialize(dashboard_id:, card_id:)
    @card_id = card_id
    @dashboard_id = dashboard_id
  end

  def call
    metabase.post_dashboard_cards(dashboard_id: dashboard_id,
                                  json: json)
  end

  private

  def json
    {
      cardId: card_id
    }
  end

  attr_reader :card_id, :dashboard_id
end
