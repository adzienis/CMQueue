# == Schema Information
#
# Table name: tag_groups
#
#  id          :bigint           not null, primary key
#  course_id   :bigint           not null
#  name        :string           not null
#  description :text             default("")
#  validations :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class TagGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
