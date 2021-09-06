class Setting < ApplicationRecord
  enum setting_type: [:boolean, :integer, :string]

  # don't know if I like this, might want to just encode in the database
  def metadata
    case key
    when "searchable"
      {
        type: :boolean,
        label: "General"
      }
    when "enrollment"
      {
        type: :boolean,
        label: "Enrollment"
      }
    when "searchable_enrollment"
      {
        type: :boolean,
        label: "Enrollment"
      }
    when "allow_enrollment"
      {
        type: :boolean,
        label: "Enrollment"
      }
    when "desktop_notifications"
      {
        type: :boolean,
        label: "Notifications"
      }
    when "site_notifications"
      {
        type: :boolean,
        label: "Notifications"
      }
    end
  end

  scope :update_all_json, ->(path,value) {
    update_all("value = jsonb_set(value::jsonb, '#{path}', '#{value}'::jsonb)::jsonb")
  }

  def update_json(path, value)
    Setting.update("value = jsonb_set(value::jsonb, '{site_notifications, value}', 'true'::jsonb)::jsonb")
  end

  def update_all_json(path, value)
    Setting.update_all("value = jsonb_set(value::jsonb, '{site_notifications, value}', 'true'::jsonb)::jsonb")
  end

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
