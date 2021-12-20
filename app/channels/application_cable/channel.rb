# frozen_string_literal: true

module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def subscribed
    end

    def request
      connection.request_var
    end

    private

    def set_variant
      agent = request.user_agent
      return request.variant = :tablet if /(tablet|ipad)|(android(?!.*mobile))/i.match?(agent)
      return request.variant = :mobile if /Mobile/.match?(agent)
      request.variant = :desktop
    end
  end
end
