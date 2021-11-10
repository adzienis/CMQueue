# == Schema Information
#
# Table name: analytics_dashboards
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  course_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class Analytics::DashboardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
