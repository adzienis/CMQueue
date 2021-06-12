module QueueAPI

  class CourseAPI < Grape::API

    helpers Helpers

    resource :courses do

      desc "Answer the topmost question in the course."
      post ':course_id/answer' do
        top_question = Question.questions_by_state(["unresolved"]).first

        top_question.question_states.create(state: params[:answer][:state], user_id: params[:answer][:user_id])
        top_question
      end

      desc "Search for courses by name."
      params do
        requires :name, type: String
      end
      get 'search' do
        Course.where("name LIKE :name", name: "%#{params[:name]}%") if params[:name]
      end

      desc 'Get all courses'
      get do
        Course.accessible_by(current_ability)
      end

      get ':course_id/open_status' do
        Course.find(params[:course_id]).open
      end

      post ':course_id/open' do
        course = Course.find(params[:course_id]).update(open: params[:open][:status])

        course
      end

      get ':course_id/activeTAs' do

        course = Course.find(params[:course_id])
        tas = User.with_role :ta, course
        tas = tas.joins(:question_state).where('question_states.created_at > ?', 15.minutes.ago).distinct

        tas
      end

      get ':course_id/topQuestion' do

        question_state = User.find(params[:user_id]).question_state
        top_question = Question.joins(:question_state).where("question_states.id": question_state&.id).includes(:user).first

        puts "-----------------------------------------------------asds"
        puts top_question.to_json

        if question_state&.state == "resolving"
          top_question.as_json include: [:user, :question_state, :tags]
        else
          nil
        end
      end
    end
  end
end