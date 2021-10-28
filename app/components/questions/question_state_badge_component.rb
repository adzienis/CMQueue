class Questions::QuestionStateBadgeComponent < ViewComponent::Base
  def initialize(state:)
    @state = state
  end

  def class_param
    bg_class = if state == "unresolved"
                 "bg-unresolved"
               elsif state == "resolving"
                 "bg-resolving"
               elsif state == "frozen"
                 "bg-frozen"
               elsif state == "kicked"
                 "bg-kicked"
               elsif state == "resolved"
                 "bg-resolved"
               end

    "badge rounded-pill #{bg_class}"
  end

  private

  attr_reader :state
end
