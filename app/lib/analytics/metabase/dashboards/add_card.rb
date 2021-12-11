class Analytics::Metabase::Dashboards::AddCard
  def initialize(card_id:)
    @card_id = card_id
  end

  def call
    {
      cardId: card_id
    }
  end

  private

  attr_reader :card_id
end
