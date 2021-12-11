class Analytics::DashboardsController < ApplicationController
  load_and_authorize_resource id_param: :dashboard_id, param_method: :dashboard_params

  def current_ability
    @current_ability ||= Analytics::DashboardAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  respond_to :html

  def index
    authorize! :index, Analytics::Dashboard
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
    @dashboard = Analytics::Dashboard.new(dashboard_params)
    @dashboard.save
    respond_with(@dashboard, location: course_dashboards_path(@course))
  end

  def update
    @dashboard.update(dashboard_params)
    respond_with(@dashboard)
  end

  def destroy
    @dashboard.destroy
    respond_with(@dashboard, location: course_forms_dashboards_path(@course))
  end

  private

  def set_dashboard
    @dashboard = Analytics::Dashboard.find(params[:dashboard_id])
  end

  def dashboard_params
    params.require(:dashboard).permit(:url, :title, :course_id)
  end
end
