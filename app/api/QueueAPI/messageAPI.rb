module QueueAPI

  class MessageAPI < Grape::API
    helpers Helpers

    namespace 'questions/:question_id' do
      resource :messages do
        desc "Get all messages associated with a question."
        get do
          messages = Message.accessible_by(current_ability).joins(:question_state).where("question_states.question_id": params[:question_id]) if params[:question_id]
          messages
        end
      end
    end

    resource :tags do

    end
  end
end