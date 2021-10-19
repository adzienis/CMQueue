
# Wrapper around Metabase
#
# Caches responses
class Analytics::Metabase
  BASE_URL= "http://office-hours-01.andrew.cmu.edu:3010"

  URL_MAPPING={
    session: -> { "#{BASE_URL}/api/session"},
    collections: -> { "#{BASE_URL}/api/collection" },
    collection_items: ->(collection_id) { "#{BASE_URL}/api/collection/#{collection_id}/items" }
  }

  def initialize
    super
  end

  # @return [Hash, NilClass]
  def guard_response_and_convert
    begin
      resp = yield

      if resp.status == 401
        remove_class_variable(@@session)
        login(@@username, @@password)
        resp = yield
      elsif resp.status != 200
        raise Exception.new(resp.status)
      end

      JSON.parse(resp.to_s)
    end
  end

  def login(username, password)
    @@username ||= username
    @@password ||= password
    return @@session if defined? @@session


    resp =  HTTP.headers("Content-Type": "application/json")
          .post(URL_MAPPING[:session].call,
                body: {
                  username: @@username,
                  password: @@password
                }.to_json)

    if resp.status != 200
      raise Exception.new(resp.status)
    end

    json = JSON.parse(resp.to_s)

    @@session = json&.fetch('id', nil)
  end

  def collections
    @collections ||= guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:collections].call)
    end
  end

  def collection_items(collection_id)
    @collection_items = guard_response_and_convert do
      HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:collection_items].call(collection_id))
    end
  end

  private

  def login_request(username, password)

  end
end