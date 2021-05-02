class MessagesController < ApplicationController
  def index
    @messages = Message.all
    @messages = @messages
                  .left_joins(:question_state)
                  .where("question_states.question_id = #{params[:question_id]}") if params[:question_id]

    respond_to do |format|
      format.html
      format.json { render json: @messages, include: :question_state }
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
  end

  def destroy
  end

  private

  def message_params
    params.require(:message).permit(:user_id, :question_id, :question_state_id, :description, :seen)
  end
end
