# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id            :bigint           not null, primary key
#  course_id     :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :text
#  tried         :text
#  description   :text
#  notes         :text
#  location      :text
#  discarded_at  :datetime
#  enrollment_id :bigint           not null
#
require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
  end

  test "is invalid without description" do
  end

  test "is invalid without location" do
  end

  test "is invalid without tried" do
  end

  test "is invalid without tags" do
  end

  test "can't create duplicate question for same enrollment" do
  end

  test "newly created question is unresolved" do
  end

  test "answering question is resolving" do
  end

  test "resolve answered question is resolved" do
  end

  test "unresolved question cannot be unresolved" do
  end

  test "unresolved question can transition to resolving" do
  end

  test "unresolved question can transition to frozen" do
  end

  test "unresolved question can transition to kicked" do
  end

  test "resolving question can transition to unresolved" do
  end
  test "resolving question can transition to resolved" do
  end
  test "resolving question can transition to frozen" do
  end
  test "resolving question can transition to kicked" do
  end

  test "resolving question can't transition to resolving" do
  end

  test "resolved question can't transition to unresolved" do
  end

  test "resolved question can't transition to resolving" do
  end
  test "resolved question can't transition to resolved" do
  end

  test "resolved question can't transition to frozen" do
  end

  test "resolved question can't transition to kicked" do
  end

  test "frozen question can transition to unresolved" do
  end

  test "frozen question can't transition to resolving" do
  end

  test "frozen question can't transition to frozen" do
  end

  test "frozen question can't transition to kicked" do
  end

  test "frozen question can't transition to resolved" do
  end

  test "kicked question can't transition to unresolved" do
  end

  test "kicked question can't transition to resolving" do
  end

  test "kicked question can't transition to resolved" do
  end

  test "kicked question can't transition to frozen" do
  end

  test "kicked question can't transition to kicked" do
  end
end
