class AccountsController < ApplicationController
  respond_to :html

  def index
  end

  def show
  end

  def edit
  end

  def update
    current_user.update(account_params)

    respond_with current_user, location: account_path
  end

  def account_params
    params.require(:user).permit(:given_name, :family_name, :email)
  end
end
