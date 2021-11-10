class Analytics::Metabase::Collections::Create
  def initialize(name:, parent_id: nil)
    @name = name
    @parent_id = parent_id
  end

  def call
    {
      "name": name,
      "description": nil,
      "color": "#509EE3",
      "parent_id": parent_id
    }
  end

  private

  attr_reader :name, :parent_id

end