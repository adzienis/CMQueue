class Courses::SettingsController < ApplicationController
  def index
    @course = Course.find(params[:id])

    @tags = Course.find(params[:id]).tags
  end
end
