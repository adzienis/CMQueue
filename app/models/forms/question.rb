class Forms::Question
  include ActiveModel::Model

  attr_reader :model
  delegate :location, :tried, :description, :tag_ids, :enrollment_id, :tags, :course, to: :question

  attr_accessor(
    :question,
    :current_user,
    :question_params
  )

  def persisted?
    question.present?
  end

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
  validate :question_valid?

  def question_valid?
    @question.valid?
  end

  def tag_groups_satisfied
    course.tag_groups.each do |tag_group|
      if tag_group.tags.count > 0 and (tag_ids & tag_group.tags.map { |tag| tag.id }).empty?
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
