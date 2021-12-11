# frozen_string_literal: true

# == Schema Information
#
# Table name: enrollments
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  role_id      :bigint
#  semester     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#
require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
