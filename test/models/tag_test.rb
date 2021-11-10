# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id           :bigint           not null, primary key
#  course_id    :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  archived     :boolean          default(TRUE)
#  name         :text             default("")
#  description  :text             default("")
#  discarded_at :datetime
#
require 'test_helper'

class TagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
