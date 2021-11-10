class Analytics::Metabase::Card::New
  def initialize(metabase:, json: )
    @metabase = metabase
    @json = json
  end

  def call
    metabase.post_card(json: json)
  end

  attr_reader :metabase, :json
end