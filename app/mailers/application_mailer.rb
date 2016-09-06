class ApplicationMailer < ActionMailer::Base
  default from: 'service@iflight.herokuapp.com'
  layout 'mailer'

  def get_recipients_email(recipient_email)
    recipient_email + "; " + ENV['EMAIL_ADMIN']
  end
end
