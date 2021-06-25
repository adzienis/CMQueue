# frozen_string_literal: true

require 'test_helper'

module Users
  class CoursesControllerTest < ActionDispatch::IntegrationTest
    test 'should get show' do
      get users_courses_show_url
      assert_response :success
    end

    test 'should get index' do
      get users_courses_index_url
      assert_response :success
    end
  end
end
