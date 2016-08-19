# Preview all emails at http://localhost:3000/rails/mailers/flight_mailer
class FlightMailerPreview < ActionMailer::Preview
  def share_cheap_flight
    FlightMailer.share_cheap_flight()
  end
end
