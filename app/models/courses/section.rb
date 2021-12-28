# == Schema Information
#
# Table name: courses_sections
#
#  id         :bigint           not null, primary key
#  course_id  :bigint
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Courses::Section < ApplicationRecord
  belongs_to :course
  has_and_belongs_to_many :enrollments
end
