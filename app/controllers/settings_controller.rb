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
    @settings = Setting.update(settings_params.keys, settings_params.values.map{|v| { value: v } })
  end

  def delete
  end

  def settings_params
    params.permit(*current_user.settings.map{|v| v.id.to_s.to_sym })
  end
end
