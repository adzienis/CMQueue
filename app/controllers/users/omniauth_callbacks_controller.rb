class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::SignInOut

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    #byebug
    if @user.persisted?

      #byebug
      puts "----------------asd"
      puts request.env["omniauth.auth"]

      session[:user_id] = @user.id
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to new_user_session_url
    end
  end

  def failure
    redirect_to root_path
  end

  def after_omniauth_failure_path_for(_scope)
    new_user_session_path
  end
end
