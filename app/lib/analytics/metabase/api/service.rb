module Analytics
  module Metabase
    module API
      class Service
        include Singleton

        BASE_URL = Rails.configuration.general[:analytics_url]

        URL_MAPPING = {
          session: -> { "#{BASE_URL}/api/session" },
          collections: -> { "#{BASE_URL}/api/collection" },
          collection: ->(collection_id) { "#{BASE_URL}/api/collection/#{collection_id}" },
          collection_items: ->(collection_id) { "#{BASE_URL}/api/collection/#{collection_id}/items" },
          card: -> { "#{BASE_URL}/api/card" },
          dashboard_cards: ->(dashboard_id) { "#{BASE_URL}/api/dashboard/#{dashboard_id}/cards" },
          dashboards: -> { "#{BASE_URL}/api/dashboard/" },
          dashboard: ->(dashboard_id) { "#{BASE_URL}/api/dashboard/#{dashboard_id}" },
          databases: -> { "#{BASE_URL}/api/database/" },
          database_fields: ->(database_id) { "#{BASE_URL}/api/database/#{database_id}/fields" },
          sync_database: ->(database_id) { "#{BASE_URL}/api/database/#{database_id}/sync_schema" }
        }

        def initialize(username: Rails.application.credentials.metabase[:username],
          password: Rails.application.credentials.metabase[:password])
          @@username = username
          @@password = password
        end

        # @return [Hash, NilClass]
        def guard_response_and_convert
          login unless defined?(@@session)

          resp = yield

          if resp.status == 401
            login(status: resp.status)
            resp = yield
          elsif !resp.status.success?
            raise StandardError.new(resp.status)
          end

          JSON.parse(resp.to_s)
        end

        def login(status: nil)
          remove_class_variable(@@session) if status.present? && status.status == 401
          return @@session if defined?(@@session)

          resp = HTTP.headers("Content-Type": "application/json")
            .post(URL_MAPPING[:session].call,
              body: {
                username: @@username,
                password: @@password
              }.to_json)

          raise StandardError.new(resp.status) unless resp.status.success?

          json = JSON.parse(resp.to_s)

          @@session = json&.fetch("id", nil)
        end

        def root_collection
          @root_collection ||= collections.find { |v| v.id == "root" }
        end

        def collections
          json_resp = guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:collections].call)
          end

          json_resp.map { |collection| Analytics::Metabase::API::Collection.new(collection: collection) }
        end

        def databases
          json_resp = guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:databases].call)
          end
          json_resp["data"].map { |collection| Analytics::Metabase::API::Database.new(database: collection) }
        end

        def database_fields(database_id)
          json_resp = guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:database_fields].call(database_id))
          end
        end

        def post_collection(json:)
          guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:collections].call, json: json)
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

        def put_collection(collection_id:, json:)
          guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).put(URL_MAPPING[:collection].call(collection_id), json: json)
          end
        end

        def get_dashboard(dashboard_id:)
          guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).get(URL_MAPPING[:dashboard].call(dashboard_id))
          end
        end

        def post_dashboard_cards(dashboard_id:, json:)
          guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:dashboard_cards].call(dashboard_id), json: json)
          end
        end

        def sync_database(database_id:)
          guard_response_and_convert do
            HTTP.headers("X-Metabase-Session": @@session).post(URL_MAPPING[:sync_database].call(database_id))
          end
        end

        def root_db
          @db ||= databases.find { |v| v.name == "local" }
        end

        def schema_fields(table_name: nil, schema: nil)
          fields = database_fields(root_db.id)
          fields = fields.filter { |v| v["table_name"] == table_name } if table_name.present?
          fields = fields.filter { |v| v["schema"] == schema } if schema.present?
          fields.map { |v| [v["name"], v.except("name").to_h] }.to_h
        end

        private

        def login_request(username, password)
        end
      end
    end
  end
end
