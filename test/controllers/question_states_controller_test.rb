# frozen_string_literal: true

require 'test_helper'

class QuestionStatesControllerTest < ActionDispatch::IntegrationTest
  test 'should get edit' do
    get question_states_edit_url
    assert_response :success
  end

  test 'should get show' do
    get question_states_show_url
    assert_response :success
  end
end
