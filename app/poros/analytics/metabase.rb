# Wrapper around Metabase
#
# Caches responses
class Analytics::Metabase
  BASE_URL = Rails.configuration.general[:analytics_url]

  URL_MAPPING = {
    session: -> { "#{BASE_URL}/api/session" },
    collections: -> { "#{BASE_URL}/api/collection" },
    collection: -> { "#{BASE_URL}/api/collection" },
    collection_items: ->(collection_id) { "#{BASE_URL}/api/collection/#{collection_id}/items" },
    card: -> { "#{BASE_URL}/api/card" },
    dashboard_cards: ->(dashboard_id) { "#{BASE_URL}/api/dashboard/#{dashboard_id}/cards" },
    dashboards: -> { "#{BASE_URL}/api/dashboard/" },
    dashboard: ->(dashboard_id) { "#{BASE_URL}/api/dashboard/#{dashboard_id}" }
  }

  def initialize(username: Rails.application.credentials.metabase[:username],
                 password: Rails.application.credentials.metabase[:password])
    @@username = username
    @@password = password
  end

  # @return [Hash, NilClass]
  def guard_response_and_convert
    begin
      login unless defined?(@@session)

      resp = yield

      if resp.status == 401
        login(status: resp.status)
        resp = yield
      elsif !resp.status.success?
        raise Exception.new(resp.status)
      end

      JSON.parse(resp.to_s)
    end
  end

  def login(status:nil)
    remove_class_variable(@@session) if status.present? && status.status == 401
    return @@session if defined?(@@session)

    resp = HTTP.headers("Content-Type": "application/json")
               .post(URL_MAPPING[:session].call,
                     body: {
                       username: @@username,
                       password: @@password
                     }.to_json)

    raise Exception.new(resp.status) unless resp.status.success?

    json = JSON.parse(resp.to_s)

    @@session = json&.fetch('id', nil)
  end

  def collections
    json_resp = guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:collections].call)
    end

    json_resp.map { |collection| Analytics::Metabase::Collection.new(collection: collection, metabase: self) }
  end

  def post_collection(json:)
    guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:collection].call, json: json)
    end
  end

  def collection_items(collection_id)
    guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:collection_items].call(collection_id))
    end
  end

  def post_card(json:)
    guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:card].call, json: json)
    end
  end

  def post_dashboard(json:)
    guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:dashboards].call, json: json)
    end
  end

  def put_dashboard(dashboard_id:, json:)
    guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).put(URL_MAPPING[:dashboard].call(dashboard_id), json: json)
    end
  end

  def post_dashboard_cards(dashboard_id:, json:)
    guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:dashboard_cards].call(dashboard_id), json: json)
    end
  end

  private

  def login_request(username, password) end
end