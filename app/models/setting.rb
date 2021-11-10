# == Schema Information
#
# Table name: settings
#
#  id            :bigint           not null, primary key
#  resource_type :string
#  resource_id   :bigint
#  value         :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
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
  scope :with_courses, ->(course_id){ where(resource_id: course_id, resource_type: "Course") }
  scope :with_parent_type, ->(parent_type) { where(resource_type: parent_type) }
  scope :with_parent_id, ->(parent_id) { where(resource_id: parent_id) }

  scope :with_key, ->(key) { where(id: from(Setting.select("*, jsonb_object_keys(value::jsonb) json_key"), :settings).where(json_key: key).pluck(:id)) }
  scope :with_key_value, ->(key, value) { where("value -> '#{key}' ->> 'value' = '#{value}'") }

  scope :update_all_json, ->(path,value) {
    update_all("value = jsonb_set(value::jsonb, '#{path}', '#{value}'::jsonb)::jsonb")
  }

  # scope like method to find a setting with key
  def self.find_by_key(key)
    with_key(key).first
  end

  def self.option_value_of_key(key)
    find_by_key(key).option_value
  end


  def key
    value.keys[0]
  end

  def option_value
    value.values.first["value"]
  end

  def set_value(new_value)
    value[key]["value"] = new_value
  end

  def update_json(path, value)
    update("value = jsonb_set(value::jsonb, '{#{path}}', '#{value}'::jsonb)::jsonb")
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
