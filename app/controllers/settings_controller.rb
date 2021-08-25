class SettingsController < ApplicationController
  load_and_authorize_resource

  before_action :restrict_routes

  def restrict_routes
    if @course
      raise CanCan::AccessDenied unless current_user.has_any_role?({name: :instructor, resource: @course})
    elsif @user
      raise CanCan::AccessDenied unless @user.id == current_user.id
    end
  end

  def index
    @settings = @settings.where(resource_id: current_user.id, resource_type: "User") if @user
    @settings = @settings.where(resource_id: @course.id, resource_type: "Course") if @course
  end

  def create
  end

  def show
    @settings = @settings.where(resource_id: current_user.id, resource_type: "User") if @user
    @settings = @settings.where(resource_id: @course.id, resource_type: "Course") if @course
  end

  def notifications
    respond_to do |format|
      format.js
    end
  end

  def update
    @settings = Setting.update(settings_params.keys, settings_params.values.map{|v| { value: v } })
    respond_to do |format|
      format.json { render json: nil}
    end
  end

  def delete
  end

  def settings_params
    params.permit(*Setting.all.accessible_by(current_ability).map{|v| v.id.to_s.to_sym })
  end
end
