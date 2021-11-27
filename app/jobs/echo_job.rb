class EchoJob < ApplicationJob
  queue_as :default

  def perform(msg)
    SpecialLogger.info msg
  end
end
