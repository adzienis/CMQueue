class Courses::QueueStatusLogController < ApplicationController
  def index
    @logs = QueueStatusLog.where(course_id: params[:course_id]).order(created_at: :desc)
    @logs = @logs.where(created_at: Date.parse(params[:date]).all_day) if params[:date].present?
  end
end
