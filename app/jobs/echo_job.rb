class EchoJob < ApplicationJob
  queue_as :default

  def perform(msg)
    SpecialLogger.info "from a job"
  end
end
