class CoursesController < ApplicationController
  def show
  end

  def index
  end

  def create
  end

  def search
    @searched_courses ||= []

    respond_to do |format|
      format.html
      format.json { render json: Course.where("name LIKE :name", name: "%#{params[:name]}%") }
    end
  end
end
