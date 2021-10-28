class Analytics::Queries::TimePerQue
  def initialize(course:)
    @course = course
  end

  def call
    query = ->(state) do
      QuestionState.where("question_id = questions.id")
                   .where("enrollment_id = enrollments.id")
                   .where(state: state)
    end

    grouped = Tag.joins(:questions).group("tags.id")


  end

  attr_reader :course
end