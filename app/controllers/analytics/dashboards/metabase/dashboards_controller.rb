class Analytics::Dashboards::Metabase::DashboardsController < ApplicationController

  respond_to :json

  before_action :required_params

  def index
    metabase = Analytics::Metabase.new

    respond_with Analytics::Metabase::Dashboards::GetCourseDashboards.new(metabase: metabase, course: @course).call
  end

  private

  def required_params
    render json: nil, status: 400 if params[:course_id].nil?
  end
end
