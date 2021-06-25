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
          questions = questions.where(user_id: params[:user_id]) if params[:user_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

          questions.count
        end

        get do
          questions = Question.undiscarded.accessible_by(current_ability).includes(:user, :question_state, :tags)
          questions = questions.where(course_id: params[:course_id]) if params[:course_id]
          questions = questions.where(user_id: params[:user_id]) if params[:user_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

          if params[:cursor]
            questions = questions.order('questions.updated_at DESC').limit(5) if params[:cursor] == '-1'
            unless params[:cursor] == '-1'
              questions = questions.where('questions.id <= ?',
                                          params[:cursor]).order('questions.updated_at DESC').limit(5)
            end
            offset = questions.offset(5).first
            return {
              data: questions.as_json(include: %i[question_state user tags]),
              cursor: offset
            }
          end

          questions.as_json include: %i[question_state user tags]
        end

        get 'position' do
          questions = Question.undiscarded.questions_by_state(JSON.parse(params[:state])) if params[:state]


          questions.pluck(:id).index(params[:question_id].to_i)
        end
      end
    end

    resource :questions do
      params do
        requires :question, type: Hash do
          requires :course_id, type: Integer
          requires :description, type: String
          requires :tried, type: String
          requires :location, type: String
          requires :user_id, type: Integer
          optional :title, type: String
        end
        requires :tags, type: Array
      end

      post scopes: [:write] do
        question = Question.create(declared(params)[:question])

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
                                       .where(user_id: question.user_id)
                                       .where(course_id: question.course_id)
                                       .order('question_states.created_at DESC')
                                       .limit(5)
      end
    end
  end
end
