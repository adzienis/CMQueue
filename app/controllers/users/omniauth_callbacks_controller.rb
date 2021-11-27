# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, :authenticate_user!
    include Devise::Controllers::SignInOut

    def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])
      if @user.persisted?
        session[:user_id] = @user.id

        # refactor demo part of app
        if ENV['DEMO']
          first_course = Course.first
          second_course = Course.second
          begin
            @user.add_role(:instructor, first_course) if first_course
          rescue ActiveRecord::RecordInvalid

          end
          begin
            @user.add_role(:student, second_course) if second_course
          rescue ActiveRecord::RecordInvalid

          end
        end

        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to new_user_session_url
      end
    end

    def test
      uri = URI("https://www.googleapis.com/oauth2/v1/userinfo?alt=json")

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new uri
        req[:Authorization] = "Bearer #{params[:access_token]}"

        response = http.request req

        @user = User.from_hash(JSON.parse(response.body))
        if @user.persisted?

          session[:user_id] = @user.id
          sign_in_and_redirect @user, event: :authentication
        else
          redirect_to new_user_session_url
        end
      end
    end

    def failure
      flash[:error] = "You have been signed out."
      redirect_to root_path
    end

    def after_omniauth_failure_path_for(_scope)
      new_user_session_path
    end
  end
end
