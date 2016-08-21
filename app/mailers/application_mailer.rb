class ApplicationMailer < ActionMailer::Base
  default from: 'service@iflight.herokuapp.com'
  layout 'mailer'
end
