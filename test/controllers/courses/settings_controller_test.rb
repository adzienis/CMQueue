# frozen_string_literal: true

require 'test_helper'

module Courses
  class SettingsControllerTest < ActionDispatch::IntegrationTest
    test 'should get index' do
      get courses_settings_index_url
      assert_response :success
    end
  end
end
