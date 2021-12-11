module Services
  class Service
    def initialize
    end

    def set_current_ability(current_ability)
      @current_ability ||= current_ability

      self
    end

    def authorize_user(*args)
      current_ability.authorize!(*args)
    end

    def authorize_user_and_perform(current_ability, *args)
      authorize_user(current_ability, *args)
      perform
    end

    def perform
    end
  end
end
