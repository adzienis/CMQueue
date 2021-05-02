class Courses::QuestionQueuesController < ApplicationController
  def create
  end

  def index
    @question_queus = Question_Queue.all

    respond_to do |format|
      format.html
      format.json { render json: Course.where("name LIKE :name", name: "%#{params[:name]}%") }
    end
  end

  def show
  end
end
