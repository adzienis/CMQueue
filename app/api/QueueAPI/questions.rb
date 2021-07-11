# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Questions < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace :courses do

      route_param :course_id do

        resource :questions do

          desc "Get the count of questions."
          params do
            optional :course_id, type: Integer
            optional :enrollment_id, type: Integer
            group :state, type: Object, coerce_with: ->(val) {
              Array(JSON.parse(val)).to_json
            }
          end
          get 'count', scopes: [:public] do

            questions = Question.undiscarded
            questions = questions.where(course_id: params[:course_id]) if params[:course_id]
            questions = questions.where(enrollment_id: params[:enrollment_id]) if params[:enrollment_id]
            questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

            questions.count
          end

          desc "Get all questions."
          params do
            optional :enrollment_id, type: Integer
            optional :state, type: Object, coerce_with: ->(val) {
              Array(JSON.parse(val)).to_json
            }
            optional :cursor, type: Integer
          end
          get scope: [:instructor] do
            questions = Question.undiscarded
            questions = questions.accessible_by(current_ability) if current_user
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
            optional :state, type: Object, coerce_with: ->(val) {
              Array(JSON.parse(val)).to_json
            }
          end
          get 'position' do
            questions = Question.undiscarded
            questions = questions.where(course_id: params[:course_id]) if params[:course_id]
            questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

            questions.pluck(:id).index(params[:question_id].to_i)
          end

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

        desc "Get question states associated with a question."
        get :question_states do
          QuestionState.where(question_id: params[:question_id])
        end

        desc "Get previous questions of a question"
        get :previousQuestions do
          question = Question.find_by(id: params[:question_id])

          error!("User not found", :bad_request) and return unless question

          questions = Question.undiscarded
          questions = questions.accessible_by(current_ability) if current_user

          questions = questions.previous_questions(question).order(:created_at)

          questions
        end

      end

      desc "Create a new question"
      params do
        requires :question, type: Hash do
          requires :enrollment_id, type: Integer
          requires :course_id, type: Integer
          requires :description, type: String
          requires :tried, type: String
          requires :location, type: String
          optional :title, type: String
          requires :question_tags_attributes, type: Array do
            requires :tag_id, type: Integer
          end
        end
      end
      post scopes: [:write] do
        question = Question.new(params[:question])

        authorize! :manage, question

        question.save!



        if !question.valid?
          error!(question.errors.messages.to_json)
          question.errors.clear
          return
        end

        question
      end
    end
  end
end
