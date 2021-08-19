class CreateCertJob < ApplicationJob
  queue_as :default

  def perform(user_id, course_id)
    system "./lib/assets/certs/root_ca/create_client_cert.sh", "course_#{course_id}_user"

    CertMailer.new_cert(user_id, course_id).deliver_later
  end
end
