module Shared
  class SettingComponent < ViewComponent::Base
    def initialize(setting:, record:)
      super
      @setting = setting
      @record = record
    end

    private

    attr_reader :setting, :record
  end
end
