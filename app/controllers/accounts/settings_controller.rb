class Accounts::SettingsController < ApplicationController
  load_and_authorize_resource id_param: :setting_id
  respond_to :html

  def current_ability
    @current_ability ||= Users::SettingAbility.new(current_user, {
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    @settings = current_user.settings
  end

  def update
    @setting.set_value(params[:setting][@setting.key] == "1")
    @setting.save

    respond_with :account, @setting, status: 303
  end

  private

  def flash_interpolation_options
    { resource_name: @setting.label }
  end
end
