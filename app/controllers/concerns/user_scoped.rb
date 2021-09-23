module UserScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_user_scoped
  end

  private

  def set_user_scoped
    @users = User.accessible_by(current_ability)
    @user = @users.find(params[:user_id]) if params[:user_id]
  end
end