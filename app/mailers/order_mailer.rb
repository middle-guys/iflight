class OrderMailer < ApplicationMailer
  helper MailerHelper

  def receipt
    @order = Order.first
    @order.flights.each do |flight|
      @flight_depart = flight if flight.depart?
      @flight_return = flight if flight.return?
    end
    @passengers = @order.passengers
    mail(to: 'coder.leo.le@gmail.com', subject: 'Receipt from iFlight')
  end
end
