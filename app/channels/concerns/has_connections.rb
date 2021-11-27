module HasConnections
  extend ActiveSupport::Concern

  class_methods do
    def connected_records
      GlobalID::Locator.locate_many(channels.map { |v| v.split(":").second })
    end

    private

    def pubsub
      @pubsub ||= ActionCable.server.pubsub
    end

    def channel_with_prefix
      @channel_prefix ||= pubsub.send(:channel_with_prefix, channel_name)
    end

    def channels
      pubsub.send(:redis_connection).pubsub('channels', "#{channel_with_prefix}:*")
    end
  end


end
