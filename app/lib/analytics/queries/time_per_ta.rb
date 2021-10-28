class Analytics::Queries::TimePerTa
  def initialize(course:)
    @course = course
  end

  def call
    query = ->(state) do
      QuestionState.where("question_id = questions.id")
                   .where("enrollment_id = enrollments.id")
                   .where(state: state)
    end

    grouped = Enrollment.undiscarded.with_course_roles(:instructor, :ta).joins(:user, :question_states, question_states: :question)
                        .merge(Question.where(id: Question.questions_by_state(:resolved).with_today))
                        .group(["enrollments.id, users.given_name, users.family_name"])
                        .select("enrollments.id as enrollment_id, users.given_name || ' ' || users.family_name as full_name, (#{Question.where(id: QuestionState
                                                                                          .where(id: QuestionState.select("max(question_states.id)").group("question_id"))
                                                                                          .where(state: "resolved").where("question_states.enrollment_id = enrollments.id")
                                                                                          .select("question_id")).with_today.select("count(*)").to_sql}) questions_total, extract(epoch from avg((#{QuestionState
                                                   .where(id: query.call("resolved").select("max(question_states.id)"))
                                                   .select(:created_at).to_sql})
                                - (#{QuestionState.where(id: query.call("resolving").select("max(question_states.id)"))
                                                  .select(:created_at).to_sql}))) avg_seconds").order("questions_total DESC")

  end

  attr_reader :course
end