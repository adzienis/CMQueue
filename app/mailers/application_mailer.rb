# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "admin@cmqueue.xyz"
  layout "mailer"
end
