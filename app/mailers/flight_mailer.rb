class FlightMailer < ApplicationMailer
  helper MailerHelper
  def share_cheap_flight
    mail(to: 'replace_this_email@gmail.com', subject: 'Your friend share cheap flight ticket with you')
  end

  def alert_notification(alert, ticket_cheaps)
  	@alert = alert
    @tickets = ticket_cheaps
    mail(to: @alert.email, subject: 'Alert BOT found something excited for you')
  end

  def alert_confirmation(alert)
    @alert = alert
    mail(to: @alert.email, subject: 'Alert confirmation from iFlight')
  end
end
