require_relative 'general_config'
require_relative 'services_config'

class AppConfig
  def self.method_missing(symbol)
    names[symbol].presence&.new || super
  end

  def self.names
    @names ||= Anyway::Config.descendants.map{|v| [v.to_s.match(/(.*)Config/)[1].downcase.to_sym , v]}.to_h
  end
end