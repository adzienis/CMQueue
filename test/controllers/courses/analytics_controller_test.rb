# frozen_string_literal: true

require 'test_helper'

module Courses
  class AnalyticsControllerTest < ActionDispatch::IntegrationTest
    test 'should get index' do
      get courses_analytics_index_url
      assert_response :success
    end
  end
end
