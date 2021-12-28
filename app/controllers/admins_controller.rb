class AdminsController < ApplicationController
  before_action :authorize_action

  def authorize_action
    raise CanCan::AccessDenied unless current_user.has_role? :admin
  end

  def index
  end

  def show
  end
end
