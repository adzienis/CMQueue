class Courses::Enrollments::ImportRecord < ApplicationRecord
  has_one_attached :record
  has_one_attached :status_log
end
