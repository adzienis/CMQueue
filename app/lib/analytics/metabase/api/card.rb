class Analytics::Metabase::API::Card
  include Metabaseable

  def initialize(card:)
    @card = card
  end

  def id
    card["id"]
  end

  def add_to_dashboard(dashboard_id)
    Analytics::Metabase::Dashboards::AddCardToDashboard.new(dashboard_id: dashboard_id,
      card_id: id).call
  end

  private

  attr_reader :card
end
