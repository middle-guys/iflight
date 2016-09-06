class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: get_recipients_email(@user.email), subject: 'Welcome <%= @user.name %> to iFlight!')
  end

  def recover_password(user)
    @user = user
    mail(to: get_recipients_email(@user.email), subject: 'Recover your password')
  end

end
