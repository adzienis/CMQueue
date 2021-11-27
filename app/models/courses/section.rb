class Courses::Section < ApplicationRecord
  belongs_to :course
  has_and_belongs_to_many :enrollments
end
