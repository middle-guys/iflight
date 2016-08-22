class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    byebug
    mail(to: @user.email, subject: 'Welcome <%= @user.name %> to iFlight!')
  end

  def recover_password(user)
    @user = user
    mail(to: @user.email, subject: 'Recover your password')
  end

end
