class ShareFlightJob < ApplicationJob
  queue_as :default

  def perform(params)
    FlightMailer.share_cheap_flight(params).deliver_later
  end
end
