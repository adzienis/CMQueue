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

  belongs_to :resource, polymorphic: true
  has_one :self_ref, class_name: name, foreign_key: :id
  has_one :course, through: :self_ref, source: :resource, source_type: "Course"
  has_one :user, through: :self_ref, source: :resource, source_type: "User"

  scope :with_key, ->(key) { where("bag::jsonb @> '{ \"key\": \"#{key}\"}'") }
  scope :with_value, ->(value) { where("bag::jsonb @> '{ \"value\": \"#{value}\"}'") }

  def self.find_by_key(key)
    with_key(key).first
  end

  def self.option_value_of_key(key)
    find_by_key(key).value
  end

  def description
    bag["description"]
  end

  def key
    bag["key"]
  end

  def label
    bag["label"]
  end

  def value
    bag["value"]
  end

  def option_value
    value.values.first["value"]
  end

  def set_value(new_value)
    bag["value"] = new_value.to_s
  end
end
