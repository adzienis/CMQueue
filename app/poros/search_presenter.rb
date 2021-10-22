class SearchPresenter

  def initialize(query_params:)
    @query_params = query_params
  end

  def build_parameters(category, key)
    if query_params[category].present?
      begin
        parsed = JSON.parse(query_params[category])
      rescue JSON::ParserError => e
        parsed = query_params[category]
      end

      if parsed.instance_of? Array
        if parsed.include? key
          parsed = parsed - [key]
        else
          parsed = parsed + [key]
        end
      else
        parsed = [parsed] + [key]
      end
      query_params.merge(category => JSON.dump(parsed))
    else
      query_params.merge(category => key)
    end
  end

  def build_class(category, key)
    if query_params[category].present?
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
    else
      ""
    end
  end

  private

  attr_reader :query_params
end