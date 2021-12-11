# frozen_string_literal: true

module Courses
  class SettingsController < ApplicationController
    load_and_authorize_resource id_param: :setting_id
    respond_to :html

    def current_ability
      @current_ability ||= Courses::SettingAbility.new(current_user, {
        params: params,
        path_parameters: request.path_parameters
      })
    end

    def index
      @settings = @course.settings
    end

    def update
      @setting = Setting.find(params[:setting_id])

      @setting.set_value(params[:setting][@setting.key] == "1")

      @setting.save!

      respond_with @course, @setting
    end

    private

    def flash_interpolation_options
      { resource_name: @setting.label }
    end
  end
end
