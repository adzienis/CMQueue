class CertificatesController < ApplicationController

  def download
    CreateCertJob.perform_later current_user.id, @course.id
  end
end
