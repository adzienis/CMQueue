# == Schema Information
#
# Table name: group_members
#
#  id              :bigint           not null, primary key
#  individual_id   :integer
#  individual_type :string
#  group_id        :integer
#  group_type      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class GroupMemberTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
