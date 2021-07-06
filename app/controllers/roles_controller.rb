class RolesController < ApplicationController
  load_and_authorize_resource

  def index
    @roles = @roles.where(resource_id: params[:course_id]) if params[:course_id]
    @course = Course.find(params[:course_id]) if params[:course_id]

    @roles_ransack = @roles.ransack(params[:q])

    @pagy, @records = pagy @roles_ransack.result
  end

  def create
  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
  end
end
