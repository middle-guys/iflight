module BookFlight
  module VietnamAirlines
    class RoundTrip < VietnamAirlinesFormulas
      attr_accessor :browser, :itinerary, :depart_flight, :return_flight, :passengers, :contact, :adult_passengers, :child_passengers, :infant_passengers

      def initialize(browser, params)
        @browser = browser
        @itinerary = params[:itinerary]
        @depart_flight = params[:depart_flight]
        @return_flight = params[:return_flight]
        @passengers = params[:passengers]
        @contact = params[:contact]
        @adult_passengers = passengers.select{ |x| x[:category] == 1 }
        @child_passengers = passengers.select{ |x| x[:category] == 2 }
        @infant_passengers = passengers.select{ |x| x[:category] == 3 }
      end

      def call
        search
        close
      end

      def search
        browser.goto "http://onlineairticket.vn/Booking/BookManage"
        browser.radio(value: "ROUNDTRIP").set
        browser.execute_script("$('#SearchRoundTripDepartureCity').val('#{itinerary[:ori_airport][:code]}')")
        browser.execute_script("$('#SearchRoundTripArrivalCity').val('#{itinerary[:des_airport][:code]}')")
        browser.execute_script("$('#SearchRoundTripDepartureDate').val('#{itinerary[:depart_date]}')")
        browser.execute_script("$('#SearchRoundTripArrivalDate').val('#{itinerary[:return_date]}')")
        browser.button(name: "btnSearchRoundTrip").click
      end

      def close
        browser.close
      end
    end
  end
end
