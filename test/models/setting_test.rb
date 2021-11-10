# == Schema Information
#
# Table name: settings
#
#  id            :bigint           not null, primary key
#  resource_type :string
#  resource_id   :bigint
#  value         :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "test_helper"

class SettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
