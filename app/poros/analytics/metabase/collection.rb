class Analytics::Metabase::Collection
  def initialize(collection:, metabase:)
    @collection = collection
    @metabase = metabase
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
      Analytics::Metabase::Card.new(card: v, metabase: metabase)
    end
  end

  def dashboards
    data.filter{|v| v["model"] == "dashboard" }.map do |v|
      Analytics::Metabase::Dashboard.new(dashboard: v, metabase: metabase)
    end
  end

  def collections
    data.filter{|v| v["model"] == "collection"}.map do |v|
      Analytics::Metabase::Collection.new(collection: v, metabase: metabase)
    end
  end

  private

  attr_reader :collection, :metabase

end