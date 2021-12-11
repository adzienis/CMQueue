class Analytics::Metabase::Dashboards::Create
  include Metabaseable

  def initialize(name:, collection_id:)
    @name = name
    @collection_id = collection_id
  end

  def call
    metabase.post_dashboard(json: json)
  end

  private

  def json
    {
      collection_id: collection_id,
      name: name
    }
  end

  attr_reader :name, :collection_id
end
