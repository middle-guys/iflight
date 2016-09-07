module Sms
  class SmsTemplateBinding
    extend DateHelper

    def self.get_content(order)
      @order = order
      @order.flights.each do |flight|
        @flight_depart = flight if flight.depart?
        @flight_return = flight if flight.return?
      end
      @ori_code = @order.ori_airport.code
      @des_code = @order.des_airport.code
      @depart_from_time = self.format_time(@flight_depart.time_depart)
      @depart_date = self.format_date(@order.date_depart)
      @depart_airline = @flight_depart.plane_category.short_name
      @depart_flight_code  = @flight_depart.code_flight
      @depart_booking_code = @flight_depart.code_book
      if @order.round_trip?
        @return_from_time = self.format_time(@flight_return.time_depart)
        @return_date = self.format_date(@order.date_return)
        @return_airline = @flight_return.plane_category.short_name
        @return_flight_code  = @flight_return.code_flight
        @return_booking_code = @flight_return.code_book
      end
      @total_price = @order.price_total
      @passengers = Sms::SmsPassengersFormatter.format(@order.passengers)
      @time_expired = self.format_date_time(Time.now + 1.days)

      sms_one_way = "HOLDING one way #{@ori_code}-#{@des_code}. DEPARTURE: #{@depart_from_time} #{@depart_date} - #{@depart_airline} (#{@depart_flight_code}) - booking code #{@depart_booking_code}. Passengers: #{@passengers}. Total #{format_currency(@total_price)}. Expired at #{@time_expired}. Hotline 0933554440"
      sms_round_trip = "HOLDING round trip #{@ori_code}-#{@des_code}. DEPARTURE: #{@depart_from_time} #{@depart_date} - #{@depart_airline} (#{@depart_flight_code}) - booking code #{@depart_booking_code}. RETURN: #{@return_from_time} #{@return_date} - #{@return_airline} (#{@return_flight_code}) - booking code #{@return_booking_code}. Passengers: #{@passengers}. Total #{format_currency(@total_price.round)}. Expired at #{@time_expired}. Hotline 0933554440"

      sms_content = @order.round_trip? ? sms_round_trip : sms_one_way
    end
  end
end