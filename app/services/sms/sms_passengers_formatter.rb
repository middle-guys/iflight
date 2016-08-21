module Sms
  class SmsPassengersFormatter
    def self.format(passengers)
      passengers_str = ""
      passengers.each do |passenger|
        passengers_str << passenger.name.upcase << ","
      end
      passengers_str.chomp(",")
    end
  end
end