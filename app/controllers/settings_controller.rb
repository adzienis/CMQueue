class SettingsController < ApplicationController
  load_and_authorize_resource id_param: :setting_id

  before_action :restrict_routes

  respond_to :html, :json

  #include ResourceInitializable
  #include ResourceAuthorizable
  #include PolymorphicFilterable
  #include PolyScopedByParent

  def restrict_routes
    if @course
      raise CanCan::AccessDenied unless current_user.has_any_role?({ name: :instructor, resource: @course })
    elsif @user
      raise CanCan::AccessDenied unless @user.id == current_user.id
    end
  end

  def index
    if params[:type].present?
      @settings = @settings.where(resource_type: params[:type], resource_id: params[:id])
    end

    respond_with @settings
  end

  def create
  end

  def show
    respond_with @settings
  end

  def notifications
    respond_to do |format|
      format.js
    end
  end

  def update
    @setting.set_value(setting_params[:value]) if setting_params.keys.include? "value"

    @setting.save

    respond_with @setting
  end

  def delete
  end

  def setting_params
    params.require(:setting).permit(:value)
  end
end
