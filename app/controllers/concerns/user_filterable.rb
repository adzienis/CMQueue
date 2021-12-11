module UserFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_user_filtered
  end

  private

  def set_user_filtered
    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }

    set_resources.call(resources.call.with_users(params[:user_id])) if params[:user_id]
  end
end
