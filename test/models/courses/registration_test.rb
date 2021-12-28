# == Schema Information
#
# Table name: courses_registrations
#
#  id            :bigint           not null, primary key
#  name          :text             not null
#  approved      :boolean          default(FALSE)
#  instructor_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class Courses::RegistrationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
