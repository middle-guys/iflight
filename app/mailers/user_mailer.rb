class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome <%= @user.name %> to iFlight!')
  end

  def recover_password(user)
    @user = user
    mail(to: @user.email, subject: 'Recover your password')
  end

	def notification_email(alert)
		@alert = alert
		@url  = 'http://example.com/login'
		mail(to: @alert.email, subject: 'Welcome to My Awesome Site')
	end
end
