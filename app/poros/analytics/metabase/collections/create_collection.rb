class Analytics::Metabase::Collections::CreateCollection
  def initialize(metabase:,name:, parent_id:nil)
    @name = name
    @parent_id = parent_id
    @metabase = metabase
  end

  def call
    metabase.post_collection(json: Analytics::Metabase::Collections::Create.new(name: name, parent_id: parent_id).call)
  end

  private

  attr_reader :name, :parent_id, :metabase
end