class Analytics::Metabase::DashboardsController < ApplicationController
  include Metabaseable

  respond_to :json, :html

  before_action :required_params

  def index
    @dashboards = Analytics::Metabase::Dashboards::GetCourseDashboards.new(course: @course).call

    respond_with @dashboards
  end

  def show
    respond_with 10
  end

  private

  def required_params
    render json: nil, status: 400 if params[:course_id].nil?
  end
end
