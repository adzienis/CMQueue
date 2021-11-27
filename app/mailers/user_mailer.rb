class UserMailer < ApplicationMailer
  default from: "admin@cmqueue.xyz"


  def invite_email
    @user = params[:user]
    mail(to: @user.email, subject: 'Invitation to CMQueue')
  end

end
