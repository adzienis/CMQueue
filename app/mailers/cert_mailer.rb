class CertMailer < ApplicationMailer
  def new_cert(user_id, course_id)
    @user = User.find(user_id)
    attachments["package.tar.bz2"] = File.read("./scripts/course_#{course_id}_user/package.tar.bz2")

    mail to: @user.email

    CleanupCertJob.perform_later course_id
  end
end
