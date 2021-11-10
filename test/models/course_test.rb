# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id              :bigint           not null, primary key
#  name            :string
#  course_code     :string
#  student_code    :string
#  ta_code         :string
#  instructor_code :string
#  open            :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
