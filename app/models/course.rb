class Course < ApplicationRecord
  has_many :enrollments
  has_many :users, through: :enrollments
  has_many :question_queues
  has_many :questions, through: :question_queues
end
