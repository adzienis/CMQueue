# frozen_string_literal: true

# == Schema Information
#
# Table name: question_states
#
#  id              :bigint           not null, primary key
#  question_id     :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :text
#  state           :integer          not null
#  enrollment_id   :bigint           not null
#  acknowledged_at :datetime
#
require 'test_helper'

class QuestionStateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
