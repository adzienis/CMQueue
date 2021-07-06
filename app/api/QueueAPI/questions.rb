# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Questions < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace 'courses/:course_id' do
      resource :questions do
        get 'count', scopes: [:public] do
          @course = Course.find(params[:course_id]) if params[:course_id]

          questions = Question.undiscarded
          questions = questions.where(course_id: params[:course_id]) if params[:course_id]
          questions = questions.where(enrollment_id: params[:enrollment_id]) if params[:enrollment_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

          questions.count
        end

        get do
          questions = Question.undiscarded.accessible_by(current_ability).includes(:question_state, :tags, :enrollment, enrollment: :user)
          questions = questions.where(course_id: params[:course_id]) if params[:course_id]
          questions = questions.where(enrollment_id: params[:enrollment_id]) if params[:enrollment_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

          if params[:cursor]
            questions = questions.order('questions.created_at asc').limit(5) if params[:cursor] == '-1'
            unless params[:cursor] == '-1'
              questions = questions.where('questions.id >= ?',
                                          params[:cursor]).order('questions.created_at asc').limit(5)
            end
            offset = questions.offset(5).first
            return {
              data: questions.as_json(include: [:question_state, :user, :tags]),
              cursor: offset
            }
          end

          questions.as_json include: [:question_state, :tags, enrollment: { include: :user }]
        end

        desc "Get the position of a question based on a query."
        params do
          optional :course_id, type: Integer
        end
        get 'position' do
          questions = Question.undiscarded
          questions = questions.where(course_id: params[:course_id]) if params[:course_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

          questions.pluck(:id).index(params[:question_id].to_i)
        end
      end
    end

    resource :questions do

      route_param :question_id do
        desc 'Handle the question.'
        params do
          requires :state, type: String
          requires :enrollment_id, type: Integer
        end
        post 'handleQuestion', scopes: [:admin] do
          question = Question.find(params[:question_id])

          question.question_states.create(state: params[:state],
                                          enrollment_id: params[:enrollment_id])
          question
        end

        get :question_states do
          QuestionState.where(question_id: params[:question_id])
        end

        get :previousQuestions do
          question = Question.find_by(id: params[:question_id])

          error!("User not found", :bad_request) and return unless question


          questions = Question.undiscarded
          questions = questions.accessible_by(current_ability) if current_user

          questions = questions.where(course_id: params[:course_id]) if params[:course_id]

          questions = questions.previous_questions(question).order(:created_at)

          questions
        end

      end

      params do
        requires :question, type: Hash do
          requires :enrollment_id, type: Integer
          requires :course_id, type: Integer
          requires :description, type: String
          requires :tried, type: String
          requires :location, type: String
          optional :title, type: String
          requires :tags, type: Array
        end
        requires :tags, type: Array
      end
      post scopes: [:write] do
        p = declared(params)
        p["question"]["tags"] = p["tags"].collect { |id| Tag.find_by(id: id) }
        question = Question.create!(p[:question])

        if !question.valid?
          error!(question.errors.messages.to_json)
          question.errors.clear
          return
        end

        question.tags = Tag.find(params[:tags])

        question
      end


      get ':question_id/paginatedPreviousQuestions' do
        question = Question.find(params[:question_id])
        paginated_previous_questions = Question
                                         .left_joins(:question_state)
                                         .where("question_states.state = #{QuestionState.states['resolved']}")
                                         .where('questions.created_at < ?', question.created_at)
                                         .where(enrollment_id: question.enrollment_id)
                                         .where(course_id: question.course_id)
                                         .order('question_states.created_at DESC')
                                         .limit(5)
      end
    end
  end
end
