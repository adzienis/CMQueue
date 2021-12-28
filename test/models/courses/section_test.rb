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
require "test_helper"

class Courses::SectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
