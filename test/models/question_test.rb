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
require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  setup do
    @student_418 = enrollments(:student_418)
    @ta_418 = enrollments(:ta_418)
    @tag_malloc = tags(:malloc)
  end

  test 'is valid with valid attributes' do
    question = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])

    assert question.errors.empty?
  end

  test "is invalid without description" do
    q = Question.create(location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])

    assert q.errors.added?(:description, :blank) and q.errors.count == 1
  end

  test "is invalid without location" do
    q = Question.create(description: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])

    assert q.errors.added?(:location, :blank) and q.errors.count == 1
  end

  test "is invalid without tried" do
    q = Question.create(description: "foo", location: "foo", enrollment: @student_418, tags: [@tag_malloc])

    assert q.errors.added?(:tried, :blank) and q.errors.count == 1
  end

  test "is invalid without tags" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418)

    assert q.errors.added?(:tags, "can't be empty") and q.errors.count == 1
  end

  test "can't create duplicate question for same enrollment" do

    Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])

    begin
      Question.create!(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    rescue ActiveRecord::StatementInvalid => e
      assert(e.message.include? "question already exists")
    end
  end

  test "newly created question is unresolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])

    assert q.question_state.state == "unresolved"
  end

  test "answering question is resolving" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.answer(@ta_418.id)

    assert q.question_state.state == "resolving"
  end

  test "resolve answered question is resolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.answer(@ta_418.id)
    q.resolve(@ta_418.id)

    assert q.question_state.state == "resolved"
  end

  test "unresolved question cannot be unresolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    ret = q.unresolve(@ta_418.id)

    assert ret.instance_of? ActiveRecord::RecordInvalid
  end

  test "unresolved question can transition to resolving" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)

    assert q.question_state.state == "resolving"
  end

  test "unresolved question can transition to frozen" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.freeze_question(@ta_418.id)

    assert q.question_state.state == "frozen"
  end

  test "unresolved question can transition to kicked" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.kick(@ta_418.id)

    assert q.question_state.state == "kicked"
  end

  test "resolving question can transition to unresolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.unresolve(@ta_418.id)

    assert q.question_state.state == "unresolved"
  end
  test "resolving question can transition to resolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.resolve(@ta_418.id)

    assert q.question_state.state == "resolved"
  end
  test "resolving question can transition to frozen" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.freeze_question(@ta_418.id)

    assert q.question_state.state == "frozen"
  end
  test "resolving question can transition to kicked" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.kick(@ta_418.id)

    assert q.question_state.state == "kicked"
  end

  test "resolving question can't transition to resolving" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    ret = q.resolving(@ta_418.id)

    assert ret.instance_of? ActiveRecord::RecordInvalid
  end

  test "resolved question can't transition to unresolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.resolve(@ta_418.id)

    q.unresolve(@ta_418.id)

    assert q.question_state.state == "resolved"
  end

  test "resolved question can't transition to resolving" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.resolve(@ta_418.id)

    q.resolving(@ta_418.id)

    assert q.question_state.state == "resolved"
  end
  test "resolved question can't transition to resolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.resolve(@ta_418.id)

    ret = q.resolve(@ta_418.id)

    assert ret.instance_of? ActiveRecord::RecordInvalid
  end

  test "resolved question can't transition to frozen" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.resolve(@ta_418.id)

    q.freeze_question(@ta_418.id)

    assert q.question_state.state == "resolved"
  end

  test "resolved question can't transition to kicked" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.resolving(@ta_418.id)
    q.resolve(@ta_418.id)

    q.kick(@ta_418.id)

    assert q.question_state.state == "resolved"
  end

  test "frozen question can transition to unresolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.freeze_question(@ta_418.id)

    q.unresolve(@ta_418.id)

    assert q.question_state.state == "unresolved"
  end

  test "frozen question can't transition to resolving" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.freeze_question(@ta_418.id)

    q.resolving(@ta_418.id)

    assert q.question_state.state == "frozen"
  end

  test "frozen question can't transition to frozen" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.freeze_question(@ta_418.id)

    ret = q.freeze_question(@ta_418.id)

    assert ret.instance_of? ActiveRecord::RecordInvalid
  end

  test "frozen question can't transition to kicked" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.freeze_question(@ta_418.id)

    q.kick(@ta_418.id)

    assert q.question_state.state == "frozen"
  end

  test "frozen question can't transition to resolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.freeze_question(@ta_418.id)

    q.resolve(@ta_418.id)

    assert q.question_state.state == "frozen"
  end

  test "kicked question can't transition to unresolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.kick(@ta_418.id)

    q.unresolve(@ta_418.id)

    assert q.question_state.state == "kicked"
  end

  test "kicked question can't transition to resolving" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.kick(@ta_418.id)

    q.resolving(@ta_418.id)

    assert q.question_state.state == "kicked"
  end

  test "kicked question can't transition to resolved" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.kick(@ta_418.id)

    q.resolve(@ta_418.id)

    assert q.question_state.state == "kicked"
  end

  test "kicked question can't transition to frozen" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.kick(@ta_418.id)

    q.freeze_question(@ta_418.id)

    assert q.question_state.state == "kicked"
  end

  test "kicked question can't transition to kicked" do
    q = Question.create(description: "foo", location: "foo", tried: "test", enrollment: @student_418, tags: [@tag_malloc])
    q.kick(@ta_418.id)

    ret = q.kick(@ta_418.id)

    assert ret.instance_of? ActiveRecord::RecordInvalid
  end

end
