# frozen_string_literal: true

require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get admin_index_url
    assert_response :success
  end

  test 'should get show' do
    get admin_show_url
    assert_response :success
  end

  test 'should get settings' do
    get admin_settings_url
    assert_response :success
  end
end
