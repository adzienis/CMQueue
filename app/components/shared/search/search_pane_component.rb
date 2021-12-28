module Shared
  module Search
    class SearchPaneComponent < ViewComponent::Base
      def initialize(query_params:, bucket:, category:, resources:, resource_path:)
        @query_params = query_params
        @bucket = bucket
        @category = category
        @resources = resources
        @resource_path = resource_path
      end

      def bucket_key
        bucket["key_as_string"] || bucket["key"]
      end

      def build_parameters(category, key)
        if query_params[category].present?
          if query_params[category].instance_of? ActiveSupport::HashWithIndifferentAccess

            hash = query_params[category]
            return query_params.except(category) if hash["key"] == bucket_key

            new_p = {}
            new_p["key"] = bucket_key
            new_p["from"] = bucket["from"] if bucket["from"].present?
            new_p["to"] = bucket["to"] if bucket["to"].present?

            query_params.merge(category => new_p)
          else
            begin
              parsed = JSON.parse(query_params[category])
            rescue JSON::ParserError => e
              parsed = query_params[category]
            end

            if parsed.instance_of? Array
              parsed = if parsed.include? key
                parsed - [key]
              else
                parsed + [key]
              end
            elsif query_params.find { |k, v| v == key }.present?
              return query_params.reject { |k, v| v == key }
            else
              return query_params.merge(category => key)
            end
            query_params.merge(category => JSON.dump(parsed))
          end
        elsif bucket["to"] || bucket["from"]
          new_p = {}
          new_p = new_p.merge({to: bucket["to"]}) if bucket["to"]
          new_p = new_p.merge({from: bucket["from"]}) if bucket["from"]
          new_p = new_p.merge({key: bucket_key}) if bucket_key
          query_params.merge(category => new_p)
        else
          query_params.merge(category => key)
        end
      end

      def build_class(category, key)
        if query_params[category].present?

          if query_params[category].instance_of? ActiveSupport::HashWithIndifferentAccess
            return "fw-bold" if bucket_key == query_params[category]["key"]

            ""
          else
            begin
              parsed = JSON.parse(query_params[category])
            rescue JSON::ParserError => e
              parsed = query_params[category]
            end

            if parsed.instance_of? Array
              parsed.include?(key) ? "fw-bold" : ""
            else
              parsed == key ? "fw-bold" : ""
            end
          end
        else
          ""
        end
      end

      private

      attr_reader :query_params, :bucket, :category, :resources, :resource_path
    end
  end
end
