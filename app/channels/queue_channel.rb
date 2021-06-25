# frozen_string_literal: true

class QueueChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user unless params[:room]

    if params[:room]
      role = Course.find_roles(:any, current_user).where(resource_id: params[:room]).first

      case params[:type]
      when 'general'
        stream_for Course.find(role.resource_id)
      when 'role'
        stream_from "#{params[:room]}##{role.name}"
      end
    end
  end

  def unsubscribed; end
end
