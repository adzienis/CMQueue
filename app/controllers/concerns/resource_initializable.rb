module ResourceInitializable
  extend ActiveSupport::Concern

  included do
    before_action :set_resource_initialized
  end

  private

  def set_resource_initialized
    instance_variable_set("@#{controller_name}", controller_name.classify.constantize.all)
  end
end