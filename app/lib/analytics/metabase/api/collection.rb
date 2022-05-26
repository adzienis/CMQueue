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

  def personal_owner_id
    collection["personal_owner_id"]
  end

  def invalidate_items
    remove_instance_variable(:@items)
  end

  def items
    @items ||= metabase.collection_items(id)
  end

  def personal?
    personal_owner_id.present?
  end

  def root?
    id == "root"
  end

  def archive
    unless personal? || root?
      metabase.put_collection(collection_id: id, json: {
        archived: true
      })
    end
  end

  def cards
    data.filter { |v| v["model"] == "card" }.map do |v|
      Analytics::Metabase::API::Card.new(card: v)
    end
  end

  def dashboards
    data.filter { |v| v["model"] == "dashboard" }.map do |v|
      Analytics::Metabase::API::Dashboard.new(dashboard: v)
    end
  end

  def collections
    data.filter { |v| v["model"] == "collection" }.map do |v|
      Analytics::Metabase::API::Collection.new(collection: v)
    end
  end

  private

  attr_reader :collection
end
