class FlightMailer < ApplicationMailer
  def share_cheap_flight
    mail(to: 'replace_this_email@gmail.com', subject: 'Your friend share cheap flight ticket with you')
  end

  def alert_confirmation
    mail(to: 'replace_this_email@gmail.com', subject: 'Alert confirmation from iFlight')
  end
end
