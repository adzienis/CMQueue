class Forms::Question
  include ActiveModel::Model

  attr_reader :model
  delegate :location, :tried, :description, :tag_ids, :course_id, :enrollment_id, :tags, :course, to: :question

  attr_accessor(
    :question,
    :current_user,
    :question_params
  )

  validate :tag_groups_satisfied

  def tag_groups_satisfied
    course.tag_groups.each do |tag_group|
      errors.add(:tags, "not included in all tag groups.") unless (tag_ids & tag_group.tags.map { |tag| tag.id }).length > 0
    end
  end

  def promote_errors(child)
    child.errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def save
    begin
      ActiveRecord::Base.transaction do
        if @question
          @question.assign_attributes(question_params)
        else
          @question = @current_user.questions.build(question_params)
        end

        raise ActiveRecord::RecordInvalid.new(self) unless valid?

        @question.save!
      end
    rescue
      promote_errors(@question) and return false
    ensure
      true
    end
  end

end
