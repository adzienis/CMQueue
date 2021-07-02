class Setting < ApplicationRecord
  enum setting_type: [ :boolean, :integer, :string ]

  after_update do

    SiteChannel.broadcast_to resource_type.constantize.find(resource_id), {
      invalidate: ['settings']
    }
  end
end
