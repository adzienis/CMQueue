class Analytics::Metabase::API::Dashboard
  extend ActiveModel::Naming
  include Metabaseable

  def initialize(dashboard:)
    @dashboard_id = dashboard["id"]
  end

  def to_key
    [id]
  end

  def id
    dashboard["id"]
  end

  def description
    dashboard["description"]
  end

  def name
    dashboard["name"]
  end

  def enable_embedding
    dashboard["enable_embedding"]
  end

  def enable_embedding!
    configure_embedding!(embedding: true)
  end

  def disable_embedding!
    configure_embedding!(embedding: false)
  end

  def dashboard
    @dashboard ||= metabase.get_dashboard(dashboard_id: dashboard_id)
  end

  def cards
    @cards ||= dashboard["ordered_cards"].map{|v| Analytics::Metabase::API::Card.new(card: v["card"]) }
  end

  def ordered_cards
    @ordered_cards ||= dashboard["ordered_cards"].map do |ordered_card|
      ordered_card["card"] = Analytics::Metabase::API::Card.new(card: ordered_card["card"])
      ordered_card
    end
  end

  def archive
    Analytics::Metabase::Dashboards::ArchiveDashboard.new(dashboard_id: id, metabase: metabase).call
  end

  def unarchive
    Analytics::Metabase::Dashboards::UnarchiveDashboard.new(dashboard_id: id, metabase: metabase).call
  end

  private

  def configure_embedding!(embedding:)
    mb.put_dashboard(dashboard_id: id, json: {
      enable_embedding: embedding
    })
  end

  attr_reader :dashboard_id
end
