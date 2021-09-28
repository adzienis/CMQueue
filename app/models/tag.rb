# frozen_string_literal: true

class Tag < ApplicationRecord
  include Discard::Model
  include RansackableConcern

  validates :name, :tag_group, presence: true

  scope :with_course, ->(course_id) do
    where(course_id: course_id)
  end
  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  belongs_to :course
  belongs_to :tag_group, optional: true

  has_many :group_members, ->{ where(group_type: "Tag")},  foreign_key: :individual_id
  has_many :tag_groups, through: :group_members, source: :group, source_type: "TagGroup"

  has_and_belongs_to_many :questions, dependent: :destroy
end
