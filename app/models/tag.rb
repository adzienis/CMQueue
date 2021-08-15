# frozen_string_literal: true

class Tag < ApplicationRecord
  include Discard::Model
  include RansackableConcern

  validates :name, presence: true
  validates_associated :questions

  scope :with_course, ->(course_id) do
    where(course_id: course)
  end
  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  belongs_to :course
  has_and_belongs_to_many :questions, dependent: :destroy
end
