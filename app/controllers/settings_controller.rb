class SettingsController < ApplicationController
  def index
  end

  def create
  end

  def show
    @settings = User.find(params[:user_id]).settings if params[:user_id]
  end

  def notifications
    respond_to do |format|
      format.js
    end
  end

  def update

    Setting.update(settings_params.keys, settings_params.values.map{|v| { value: v } })

    respond_to do |format|
      format.json { render json: nil }
      format.html { redirect_to user_settings_path(params[:user_id]) }
    end
  end

  def delete
  end

  def settings_params
    params.permit(*current_user.settings.map{|v| v.id.to_s.to_sym })
  end
end
