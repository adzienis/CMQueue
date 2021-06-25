# frozen_string_literal: true

class Course < ApplicationRecord
  resourcify

  validates :name, uniqueness: true
  validates :ta_code, presence: true, uniqueness: true
  validates :student_code, presence: true, uniqueness: true
  validates :instructor_code, presence: true, uniqueness: true

  # Not required for now
  # validates :course_code, presence: true, uniqueness: true

  has_many :enrollments
  has_many :users, through: :enrollments
  has_many :questions
  has_many :tags

  before_validation on: :create do
    self.ta_code = SecureRandom.urlsafe_base64(6) unless ta_code
    self.student_code = SecureRandom.urlsafe_base64(6) unless student_code
    self.instructor_code = SecureRandom.urlsafe_base64(6) unless instructor_code
  end

  after_update do
    QueueChannel.broadcast_to self, {
      invalidate: ['courses', id, 'open_status']
    }
  end
end
