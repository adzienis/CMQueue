# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class QuestionStates < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace 'courses/:course_id/question_states', scopes: [:public] do
      resource :ta_feed do
        get do
          time = Time.zone.now
          time = Time.zone.parse(params[:date]) if params[:date]

          states = QuestionState.all
          states = states.accessible_by(current_ability) if current_user
          states = states.with_course(Course.find_by(id: params[:course_id])) if params[:course_id]
          states = states
                     .where('question_states.created_at < ?', time.end_of_day)
                     .where('question_states.created_at > ?', time.beginning_of_day)
                     .where(state: ['resolved', 'frozen'])
                     .as_json include: :user
          states
        end
      end
    end

    resource :question_states do

      route_param :question_state_id do

      end
    end
  end
end
