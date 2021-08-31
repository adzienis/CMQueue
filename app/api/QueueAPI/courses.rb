# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Courses < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :courses do

      route_param :course_id do

        desc 'Get all settings by course.'
        get 'settings' do
          course = Course.find(params[:course_id])

          settings = course.settings

          settings.accessible_by(current_ability)
        end

        desc "Calculate the amount of time between a question resolving, and being resolved,
            grouped by staff, then by question."
        get "answer_time" do
          query = ->(state) do
            QuestionState.where("question_id = questions.id")
                         .where("enrollment_id = enrollments.id")
                         .where(state: state)
          end

          grouped = Enrollment.undiscarded.with_course_roles(:instructor, :ta).joins(:question_states, question_states: :question)
                              .merge(Question.where(id: Question.questions_by_state(:resolved).with_today))
                              .group(["enrollments.id", "questions.id"])
                              .calculate(:average, "(#{QuestionState
                                                         .where(id: query.call("resolved").select("max(question_states.id)"))
                                                         .select(:created_at).to_sql})
                                - (#{QuestionState.where(id: query.call("resolving").select("max(question_states.id)"))
                                                  .select(:created_at).to_sql})")

          grouped
        end

        desc 'Handle the topmost question in the course, by default all tags.'
        params do
          optional :tags, type: Array[Integer]
          requires :state, type: String
          requires :enrollment_id, type: Integer
          requires :course_id, type: Integer
        end
        post 'handle_question', scopes: [:admin] do

          top_question = Question.accessible_by(current_ability)
          top_question = top_question.undiscarded

          top_question = top_question
                           .joins(:tags)
                           .where("tags.name": params[:tags]) if params[:tags]

          top_question = top_question
                           .with_course(Course.find(params[:course_id]))
                           .questions_by_state(['unresolved'])
                           .order(created_at: :asc)
                           .first

          state = top_question.question_states.build(state: params[:state],
                                                     enrollment_id: params[:enrollment_id])

          authorize! :create, state

          state.save!

          top_question
        end

        desc 'Gets the open status of a course.'
        params do
          requires :course_id, type: Integer
        end
        get 'open_status', scopes: [:public] do

          course = Course.find(params[:course_id])

          authorize! :read, course

          course.open
        end

        desc 'Update the open status of a course.'
        params do
          requires :status, type: Boolean
          requires :course_id, type: Integer
        end
        post 'open', scopes: [:admin] do
          course = Course.find(params[:course_id])

          authorize! :update, course

          course.update(open: params[:status])
        end

        desc 'Get TA\'s with any activity in the past 15 minutes.'
        get 'activeTAs', scopes: [:public] do
          course = Course.find(params[:course_id])
          tas = User.enrolled_in_course(course).with_any_roles :ta, :instructor

          authorize! :read, course

          tas.joins(:enrollments, enrollments: :question_state)
             .where('question_states.created_at > ?', 15.minutes.ago)
             .merge(QuestionState.with_course(course.id))
             .distinct
        end

        desc 'Get the question at the top of the queue for a user by course.'
        params do
          optional :tag_id, type: Integer
          requires :user_id, type: Integer
        end
        get 'topQuestion', scopes: [:public] do
          course = Course.find(params[:course_id])
          question_state = User.find(params[:user_id]).question_state

          top_question = Question.joins(:question_state).where("question_states.id": question_state&.id)
          top_question = top_question.undiscarded
          top_question = top_question.with_course(course.id).first

          return nil unless top_question

          authorize! :read, top_question

          top_question.as_json include: %i[user question_state tags] if question_state&.state == 'resolving'
        end

      end

      desc 'Search for courses by name.'
      params do
        optional :name, type: String
      end
      get 'search', scopes: [:public] do
        courses = Course.all
        courses = courses.where('name LIKE :name', name: "%#{params[:name]}%") if params[:name]
        courses = courses.joins(:settings).where("value -> 'searchable' ->> 'value' = 'true'")

        courses.select(Course.column_names - [:instructor_code, :ta_code])

        authorize! :read, Course

        courses
      end

      desc 'Get all courses.'
      get scopes: [:public] do

        authorize! :read, Course

        Course.all
      end

    end
  end
end
