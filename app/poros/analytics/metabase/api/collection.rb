class Analytics::Metabase::API::Collection
  include Metabaseable

  def initialize(collection:)
    @collection = collection
  end

  def id
    collection["id"]
  end

  def data
    items["data"]
  end

  def name
    collection["name"]
  end

  def invalidate_items
    remove_instance_variable(:@items)
  end

  def items
    @items ||= metabase.collection_items(id)
  end

  def cards
    data.filter{|v| v["model"] == "card" }.map do |v|
      Analytics::Metabase::API::Card.new(card: v)
    end
  end

  def dashboards
    data.filter{|v| v["model"] == "dashboard" }.map do |v|
      Analytics::Metabase::API::Dashboard.new(dashboard: v)
    end
  end

  def collections
    data.filter{|v| v["model"] == "collection"}.map do |v|
      Analytics::Metabase::API::Collection.new(collection: v)
    end
  end

  private

  attr_reader :collection
end
