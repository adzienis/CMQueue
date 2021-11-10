class Analytics::Metabase::Dashboards::Create
  def initialize(collection_id:, name:)
    @collection_id = collection_id
    @name = name
  end

  def call
    {
      collection_id: collection_id,
      name: name
    }
  end

  private

  attr_reader :collection_id, :name

end