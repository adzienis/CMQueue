class SpecialLogger

  def self.logger
    return @@logger if defined? @@logger

    @@logger = Logger.new(Rails.root.join('log', 'special.log'))
    @@logger.level = 'debug'

    @@logger
  end

  class << self
    delegate :debug, :info, :warn, :error, :fatal, to: :logger
  end
end
