class Analytics::Metabase::Dashboards::CreateDashboard
  def initialize(metabase:, name:, collection_id:)
    @name = name
    @collection_id = collection_id
    @metabase = metabase
  end

  def call
    metabase.post_dashboard(json: Analytics::Metabase::Dashboards::Create.new(collection_id: collection_id,
                                                                              name: name).call)
  end

  private

  attr_reader :name, :collection_id, :metabase
end