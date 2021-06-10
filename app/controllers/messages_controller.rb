class MessagesController < ApplicationController
  load_and_authorize_resource

  def index

    respond_to do |format|
      format.html {
        @messages = @messages.joins(question_state: :question).where("questions.course_id": params[:course_id]) if params[:course_id]
        @course = Course.find(params[:course_id]) if params[:course_id]

        @messages_ransack = @messages.ransack(params[:q])

        @pagy, @records = pagy @messages_ransack.result
      }
      format.json {

        @messages = Message.all
        @messages = @messages
                      .left_joins(:question_state)
                      .where("question_states.question_id = #{params[:question_id]}") if params[:question_id]

        render json: @messages, include: :question_state
      }
    end
  end

  def update
    @message = Message.find(params[:id]).update(message_params)

    respond_to do |format|
      format.html
      format.json { render json: @message }
    end
  end

  def create
    @message = Message.create!(message_params)

    respond_to do |format|
      format.html
      format.json { render json: @message }
    end
  end

  def show
    @message = Message.find(params[:id])
    @course = @message.course
  end

  def destroy
  end

  private

  def message_params
    params.require(:message).permit(:user_id, :question_id, :question_state_id, :description, :seen)
  end
end
