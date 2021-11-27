class Users::AuthenticatedController < ApplicationController
  respond_to :json

  def show
    if user_signed_in?
      head :ok
    else
      head :unauthorized
    end
  end
end
