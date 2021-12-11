require "./lib/responders/csv_responder"

module ActionController
  class Responder
    # override api_behavior so patches/puts return modified object
    def api_behavior
      raise MissingRenderer.new(format) unless has_renderer?

      if get?
        display resource
      elsif post?
        display resource, status: :created, location: api_location
      elsif patch?
        display resource
      elsif put?
        display resource
      else
        head :no_content
      end
    end
  end
end

class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::CollectionResponder
  include Responders::CsvResponder
end
