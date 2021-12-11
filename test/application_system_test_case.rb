# frozen_string_literal: true

require "test_helper"

def log_errors(page)
  errors = page.driver.browser.manage.logs.get(:browser)
  if errors.any?
    errors.each do |error|
      warn error.message
    end
  end
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Devise::Test::IntegrationHelpers

  fixtures(:all)

  teardown do
    log_errors(page)
  end

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400] do |option|
    option.add_argument "no-sandbox"
    option.add_argument "headless"
  end
end
