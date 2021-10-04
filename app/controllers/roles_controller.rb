class RolesController < ApplicationController
  load_and_authorize_resource id_param: :role_id

  def index
    @roles = @roles.where(resource_id: params[:course_id]) if params[:course_id]

    @roles_ransack = @roles.ransack(params[:q])

    @pagy, @records = pagy @roles_ransack.result
  end

  def create
  end

  def show
  end
end
