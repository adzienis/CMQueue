require 'doorkeeper/grape/helpers'
module QueueAPI
  class QuestionAPI < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    namespace 'courses/:course_id' do
      resource :questions do
        get 'count' do

          @course = Course.find(params[:course_id]) if params[:course_id]

          questions = Question
          questions = questions.where(course_id: params[:course_id]) if params[:course_id]
          questions = questions.where(user_id: params[:user_id]) if params[:user_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]
          
          questions.count
        end

        get do
          questions = Question.accessible_by(current_ability).includes(:user, :question_state, :tags)
          questions = questions.where(course_id: params[:course_id]) if params[:course_id]
          questions = questions.where(user_id: params[:user_id]) if params[:user_id]
          questions = questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

          if params[:cursor]
            questions = questions.order("questions.updated_at DESC").limit(5) if params[:cursor] == "-1"
            questions = questions.where('questions.id <= ?', params[:cursor]).order("questions.updated_at DESC").limit(5) unless params[:cursor] == "-1"
            offset = questions.offset(5).first
            return {
              data: questions.as_json(include: [:question_state, :user, :tags]),
              cursor: offset
            }
          end

          questions.as_json include: [:question_state, :user, :tags]
        end

      end
    end

    resource :questions do

      get ':question_id/paginatedPreviousQuestions' do

        question = Question.find(params[:question_id])
        paginated_previous_questions = Question
                                         .left_joins(:question_state)
                                         .where("question_states.state = #{QuestionState.states["resolved"]}")
                                         .where("questions.created_at < ?", question.created_at)
                                         .where(user_id: question.user_id)
                                         .where(course_id: question.course_id)
                                         .order("question_states.created_at DESC")
                                         .limit(5)
        paginated_previous_questions
      end

    end

  end
end