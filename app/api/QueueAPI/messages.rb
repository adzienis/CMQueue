# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Messages < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace 'questions/:question_id' do
      resource :messages do
        desc 'Get all messages associated with a question. Deprecated'
        get do
          if params[:question_id]
            messages = Message.accessible_by(current_ability).joins(:question_state).where("question_states.question_id": params[:question_id])
          end
          messages.as_json include: [:question_state]
        end
      end
    end

    resource :tags do
    end
  end
end
