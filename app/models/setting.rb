class Setting < ApplicationRecord
  enum setting_type: [:boolean, :integer, :string]

  after_update do

    case resource_type
    when "Course"
      QueueChannel.broadcast_to resource_type.constantize.find(resource_id), {
        invalidate: ['settings']
      }
    when "User"
      SiteChannel.broadcast_to resource_type.constantize.find(resource_id), {
        invalidate: ['settings']
      }
    end
  end
end
