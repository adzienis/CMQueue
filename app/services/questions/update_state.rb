module Questions
  class UpdateState
    def initialize(question:, enrollment:, state:, description: "", options: {})
      @question = question
      @state = state
      @enrollment = enrollment
      @description = description
      @options = options
    end

    def call
      @error = question.transition_to_state(state, enrollment.id, description: description)

      return nil if error.present?

      return nil unless update_creator?

      if state == "resolved"
        RenderComponentJob.perform_later("Forms::Questions::QuestionCreatorComponent",
                                         question.user,
                                         opts: { target: "form" },
                                         component_args: { course: course,
                                                           question: nil,
                                                           current_user: question.user
                                         })
      else
        RenderComponentJob.perform_later("Forms::Questions::QuestionCreatorComponent",
                                         question.user,
                                         opts: { target: "form" },
                                         component_args: { course: course,
                                                           question: question,
                                                           current_user: question.user
                                         })
      end
      nil
    end

    attr_reader :error

    private

    def course
      question.course
    end

    def update_creator?
      options[:update_creator?].present?
    end

    attr_reader :question, :state, :enrollment, :description, :options
  end
end
