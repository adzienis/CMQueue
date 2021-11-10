# frozen_string_literal: true

# == Schema Information
#
# Table name: announcements
#
#  id          :bigint           not null, primary key
#  title       :string           default("")
#  description :text             default("")
#  visible     :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
