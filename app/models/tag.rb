# frozen_string_literal: true

class Tag < ApplicationRecord
  include Discard::Model
  include Ransackable

  validates :name, presence: true

  scope :with_course, ->(course_id) do
    where(course_id: course_id)
  end
  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  belongs_to :course

  has_many :group_members, -> { where(individual_type: "Tag") }, foreign_key: :individual_id, as: :individual, inverse_of: :individual
  has_many :tag_groups, through: :group_members, as: :group, source: :group, source_type: "TagGroup", inverse_of: :tags

  has_and_belongs_to_many :questions, dependent: :destroy
end
