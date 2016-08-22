class OrderMailer < ApplicationMailer
  helper MailerHelper

  def receipt(order)
    @order = order
    @order.flights.each do |flight|
      @flight_depart = flight if flight.depart?
      @flight_return = flight if flight.return?
    end
    @passengers = @order.passengers
    mail(to: @order.contact_email, subject: 'Order information from iFlight')
  end

  def error(order)
    @order = order
    @order.flights.each do |flight|
      @flight_depart = flight if flight.depart?
      @flight_return = flight if flight.return?
    end
    @passengers = @order.passengers
    mail(to: @order.contact_email, subject: 'Order information from iFlight')
  end
end
