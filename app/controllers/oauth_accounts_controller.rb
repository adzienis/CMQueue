# frozen_string_literal: true

class OauthAccountsController < ApplicationController
  include Devise::Controllers::SignInOut

  skip_before_action :authenticate_user!, :verify_authenticity_token, raise: false
  protect_from_forgery with: :null_session

  def create_or_update
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?

      session[:user_id] = @user.id
      sign_in @user

      render json: request.env["omniauth.auth"]
    else
      redirect_to new_user_session_url
    end
  end

  def error
  end
end
