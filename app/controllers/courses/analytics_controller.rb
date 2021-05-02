class Courses::AnalyticsController < ApplicationController
  def index
    @course = Course.find(params[:id])
  end
end
