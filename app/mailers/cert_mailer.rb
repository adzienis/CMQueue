class CertMailer < ApplicationMailer

  def new_cert(user_id, course_id)
    @user = User.find(user_id)
    attachments['package.tar.gz'] = File.read("./scripts/course_#{course_id}_user/package.tar.gz")

    mail to: @user.email

    CleanupCertJob.perform_later course_id
  end
end
