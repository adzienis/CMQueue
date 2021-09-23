class SummariesController < ApplicationController

  respond_to :json

  def grouped_tags
    @tags = Tag.accessible_by(current_ability)
    @tags = @tags.with_course(params[:course_id])
    @tags = @tags.undiscarded
    @tags = @tags.joins(:questions).merge(Question.undiscarded.latest_by_state(JSON.parse(params[:state]))) if params[:state]
    @tags = @tags.where(id: params[:tags]) if params[:tags]
    @tags = @tags.group(:id).count

    respond_with @tags
  end

  def activity
    time = Time.zone.now
    time = Time.zone.parse(params[:date]) if params[:date]

    @states = QuestionState.all
    @states = @states.accessible_by(current_ability)
    @states = @states.with_course(@course.id) if params[:course_id]
    @states = @states
                .where('question_states.created_at < ?', time.end_of_day)
                .where('question_states.created_at > ?', time.beginning_of_day)
                .where(state: ['resolved', 'frozen', 'resolving'])

    respond_with @states
  end

  def recent_activity
    tas = User.enrolled_in_course(@course).with_any_roles :ta, :instructor

    authorize! :read, @course

    tas = tas.joins(:enrollments, enrollments: :question_state)
       .where('question_states.created_at > ?', 15.minutes.ago)
       .merge(QuestionState.with_course(@course.id))
       .distinct(:id)

    respond_with tas
  end

  def answer_time
    query = ->(state) do
      QuestionState.where("question_id = questions.id")
                   .where("enrollment_id = enrollments.id")
                   .where(state: state)
    end

    enrollments = Enrollment.undiscarded
    enrollments = enrollments.with_role(@course.id) if params[:course_id]

    enrollments = enrollments.with_course_roles(:instructor, :ta)
    grouped = enrollments.joins(:question_states, question_states: :question)
                         .merge(Question.where(id: Question.questions_by_state(:resolved).with_today))
                         .group(["enrollments.id", "questions.id"])
                         .calculate(:average, "(#{QuestionState
                                                    .where(id: query.call("resolved").select("max(question_states.id)"))
                                                    .select(:created_at).to_sql})
                                - (#{QuestionState.where(id: query.call("resolving").select("max(question_states.id)"))
                                                  .select(:created_at).to_sql})")

    respond_with grouped
  end
end
