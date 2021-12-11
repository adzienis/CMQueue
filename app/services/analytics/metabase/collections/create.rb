class Analytics::Metabase::Collections::Create
  include Metabaseable

  def initialize(name:, parent_id: nil)
    @name = name
    @parent_id = parent_id
  end

  def call
    metabase.post_collection(json: json)
  end

  private

  def json
    {
      "name": name,
      "description": nil,
      "color": "#509EE3",
      "parent_id": parent_id
    }
  end

  attr_reader :name, :parent_id
end
