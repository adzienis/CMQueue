class Analytics::DashboardsController < ApplicationController
  load_and_authorize_resource id_param: :dashboard_id, param_method: :analytics_dashboard_params

  respond_to :html

  def index
    @dashboards = Analytics::Dashboard.all
    respond_with(@dashboards)
  end

  def show
    respond_with(@dashboard)
  end

  def new
    @dashboard = Analytics::Dashboard.new
    respond_with(@dashboard)
  end

  def edit
  end

  def create
    @dashboard = Analytics::Dashboard.new(analytics_dashboard_params)
    @dashboard.save
    respond_with(@dashboard, location: course_analytics_dashboards_path(@course))
  end

  def update
    @dashboard.update(analytics_dashboard_params)
    respond_with(@dashboard)
  end

  def destroy
    @dashboard.destroy
    respond_with(@dashboard, location: course_forms_analytics_dashboards_path(@course))
  end

  private
    def set_analytics_dashboard
      @dashboard = Analytics::Dashboard.find(params[:dashboard_id])
    end

    def analytics_dashboard_params
      params.require(:analytics_dashboard).permit(:url, :title, :course_id)
    end
end
