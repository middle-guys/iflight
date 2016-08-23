class OrderMailer < ApplicationMailer
  helper MailerHelper

  def receipt(order)
    @order = order
    @order.flights.each do |flight|
      @flight_depart = flight if flight.depart?
      @flight_return = flight if flight.return?
    end
    @passengers = @order.passengers
    mail(to: @order.contact_email, subject: 'Order successful - from iFlight')
  end

  def booking_failed(order)
    @order = order
    @order.flights.each do |flight|
      @flight_depart = flight if flight.depart?
      @flight_return = flight if flight.return?
    end
    @passengers = @order.passengers
    mail(to: @order.contact_email, subject: 'Order failed - from iFlight')
  end
end
