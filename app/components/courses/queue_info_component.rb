module Courses
  class QueueInfoComponent < ViewComponent::Base
    def info
      raise NotImplementedError
    end

    def title
      raise NotImplementedError
    end

    def footer
      raise NotImplementedError
    end

    def value
      raise NotImplementedError
    end
  end
end
