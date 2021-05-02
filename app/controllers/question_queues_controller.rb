class QuestionQueuesController < ApplicationController
  def create
  end

  def show
  end

  def index
    @question_queues = QuestionQueue.all

    @question_queues = QuestionQueue.all
    puts "asdlkasldkaskdklreeek"
    @question_queues = Course.find(params[:course_id]).question_queues if params[:course_id]

    respond_to do |format|
      format.html
      format.json { render json: @question_queues }
    end
  end

  def destroy
  end
end
