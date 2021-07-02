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
          l = QuestionState
              .accessible_by(current_ability)
              .with_course(Course.find(1))
              .where('question_states.created_at < ?', time.end_of_day)
              .where('question_states.created_at > ?', time.beginning_of_day)
              .where(state: ['resolved', 'frozen'])
              .as_json include: :user
          l
        end
      end
    end

    resource :question_states do

      route_param :question_state_id do

      end
    end
  end
end
