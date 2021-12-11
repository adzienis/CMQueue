class Analytics::Metabase::Cards::Create
  include Metabaseable

  def initialize(json: )
    @json = json
  end

  def call
    metabase.post_card(json: json)
  end

  attr_reader :json
end
