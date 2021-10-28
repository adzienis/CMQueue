module Search
  class ClauseBuilder
    def initialize(attributes:, params:)
      @attributes = attributes
      @params = params
    end

    def build_order_clauses(query_params)

      if query_params[:sort]
        split = query_params[:sort].split('_')

        attribute = split[..-2].join("_")
        order = split[-1]

        { attribute => order }
      else
        {}
      end
    end

    def build_clauses(params)
      where_params = {}

      attributes.each do |attribute|
        where_params = where_params.merge(build_clause(attribute)) if params[attribute]
      end

      where_params
    end

    private

    def build_clause(query_key)
      if params[query_key].instance_of? ActionController::Parameters
        h = params[query_key].to_unsafe_h

        if h[:to] || h[:from]
          new_p = {}

          new_p = new_p.merge({gte: h[:from]}) if h[:from]
          new_p = new_p.merge({lte: h[:to]}) if h[:to]

          { query_key => new_p }
        else
          { query_key => params[query_key].to_unsafe_h}
        end

      else
        begin
          parsed = JSON.parse(params[query_key])
        rescue JSON::ParserError
          parsed = params[query_key]
        end

        return {} if parsed.instance_of?(Array) && parsed.empty?

        { query_key => parsed }
      end
    end


    attr_reader :attributes, :params
  end
end