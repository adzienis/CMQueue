module NameFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_name_filtered
  end

  private

  def set_name_filtered
    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }

    set_resources.call(resources.call.where("name LIKE ?", params[:name])) if params[:name].present?
  end
end
