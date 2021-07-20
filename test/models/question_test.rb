# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
   test "needs location, description, tried, course_id" do
     assert_raises do
       Question.create!(description: "foo", location: "foo", tried: "test", enrollment_id: enrollments(:student_418).id)
     end
   end

   test "can't create duplicate question for same enrollment" do

     Question.create!(description: "foo", location: "foo", tried: "test", enrollment_id: enrollments(:student_418).id, course_id: courses(:class_418).id)

     assert_raises do
       Question.create!(description: "foo", location: "foo", tried: "test", enrollment_id: enrollments(:student_418).id, course_id: courses(:class_418).id)
     end
   end
end
