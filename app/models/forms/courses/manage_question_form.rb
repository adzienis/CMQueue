class Forms::Courses::ManageQuestionForm
  include ActiveModel::Model

  attr_reader :model
  delegate :location, :tried, :description, :tag_ids, :enrollment_id, :tags, :course, to: :question

  attr_accessor(
    :question,
    :current_user,
    :question_params,
    :question_state
  )

  private def method_missing(symbol, *args)
    if symbol.to_s.include? "tag_group"
      if symbol.to_s.include? "="
        instance_variable_set("@#{symbol}", *args)
      else
        instance_variable_get("@#{symbol}")
      end
    else
      super
    end
  end

  validate :tag_groups_satisfied

  def tag_groups_satisfied
    course.tag_groups.each do |tag_group|
      if (tag_group.tags.count > 0) && (tag_ids & tag_group.tags.map { |tag| tag.id }).empty?
        errors.add("tag_group_#{tag_group.id}".to_sym,
          "#{tag_group.name} missing tag")
      end
    end
  end

  def promote_errors(child)
    child.errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def save
    ActiveRecord::Base.transaction do
      if @question
        @question.assign_attributes(question_params)
      else
        @question = @current_user.questions.build(question_params)
      end

      if question_state.present?
        @question_state = @question.question_states.build(state: new_state,
          enrollment: current_user.enrollment_in_course(question.course))
        @question_state.save!
      end

      raise ActiveRecord::RecordInvalid.new(self) unless valid?

      @question.save!
    end
  rescue
    promote_errors(@question) and return false
  ensure
    @question.update!(updated_at: Time.current)
    true
  end
end
