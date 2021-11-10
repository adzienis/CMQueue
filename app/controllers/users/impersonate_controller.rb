class Users::ImpersonateController < ApplicationController
  skip_before_action :authenticate_user!

  def start_impersonating
    render head 401 and return unless Rails.env.development?
    user = User.find(params[:user_id])
    sign_in(user) and redirect_to root_path and return unless user_signed_in?

    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    render head 401 and return unless Rails.env.development?
    stop_impersonating_user
    redirect_to root_path
  end
end
