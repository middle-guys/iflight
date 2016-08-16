class UserMailer < ApplicationMailer
	default from: 'notification@example.com'
	def notification_email(alert)
		@alert = alert
		@url  = 'http://example.com/login'
		mail(to: @alert.email, subject: 'Welcome to My Awesome Site')
	end
end
