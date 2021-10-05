class Courses::DatabaseController < ApplicationController

  before_action :authorize

  def authorize
    authorize! :index_database, @course
  end

  def index
  end
end
