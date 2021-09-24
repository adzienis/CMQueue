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

  scope :with_type, ->(type) { where(resource_type: type) }
  scope :with_user, ->(user_id) { where(resource_id: user_id, resource_type: "User") }
  scope :with_course, ->(course_id){ where(resource_id: course_id, resource_type: "Course") }
  scope :with_parent_type, ->(parent_type) { where(resource_type: parent_type) }
  scope :with_parent_id, ->(parent_id) { where(resource_id: parent_id) }

  scope :update_all_json, ->(path,value) {
    update_all("value = jsonb_set(value::jsonb, '#{path}', '#{value}'::jsonb)::jsonb")
  }

  def key
    value.keys[0]
  end

  def set_value(new_value)
    value[key]["value"] = new_value
  end

  def update_json(path, value)
    Setting.update("value = jsonb_set(value::jsonb, '{#{path}}', '#{value}'::jsonb)::jsonb")
  end

  def update_all_json(path, value)
    Setting.update_all("value = jsonb_set(value::jsonb, '{#{path}}', '#{value}'::jsonb)::jsonb")
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
