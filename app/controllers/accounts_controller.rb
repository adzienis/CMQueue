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

  private

  def account_params
    params.require(:user).permit(:given_name, :family_name, :email)
  end

  def flash_interpolation_options
    {resource_name: "Account"}
  end
end
