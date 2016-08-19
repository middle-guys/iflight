class FlightMailer < ApplicationMailer
  def share_cheap_flight
    mail(to: 'coder.leo.le@gmail.com', subject: 'Your friend share cheap flight ticket with you')
  end
end
