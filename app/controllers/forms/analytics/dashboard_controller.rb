class Forms::Analytics::DashboardController < ApplicationController
  respond_to :html

  def create
    @dashboard_form = Forms::Analytics::Dashboard.new(dashboard_params)

    @dashboard_form.save

    respond_with @dashboard_form.course, @dashboard_form, location: course_analytics_dashboards_path(@dashboard_form.course)
  end

  def update
    @dashboard = Analytics::Dashboard.find(params[:dashboard_id])
    @dashboard_form = Forms::Analytics::Dashboard.new(dashboard: @dashboard, **dashboard_params)

    @dashboard_form.save

    respond_with @dashboard_form, location: course_analytics_dashboards_path(@dashboard_form.course.id)
  end

  def new
    @dashboard_form ||= Forms::Analytics::Dashboard.new

    respond_with @dashboard_form
  end

  def edit
    @dashboard ||= Analytics::Dashboard.find(params[:dashboard_id])
    @dashboard_form ||= Forms::Analytics::Dashboard.new(dashboard: @dashboard)

    respond_with @dashboard_form
  end

  def destroy
  end

  private

  def dashboard_params
    params.require(:forms_analytics_dashboard).permit(:course_id, :dashboard_type, :name, :url, :metabase_id)
  end
end
