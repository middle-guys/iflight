module BookFlight
  module VietnamAirlines
    class OneWay < VietnamAirlinesFormulas
      attr_accessor :browser, :itinerary, :depart_flight, :passengers, :contact, :adult_passengers, :child_passengers, :infant_passengers

      def initialize(browser, params)
        @browser = browser
        @itinerary = params[:itinerary]
        @depart_flight = params[:depart_flight]
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
        browser.radio(value: "ONEWAY").set
        browser.execute_script("$('#SearchOneWayDepartureCity').val('#{itinerary[:ori_airport][:code]}')")
        browser.execute_script("$('#SearchOneWayArrivalCity').val('#{itinerary[:des_airport][:code]}')")
        browser.execute_script("$('#SearchOneWayDepartureDate').val('#{itinerary[:depart_date]}')")
        browser.button(name: "btnSearhOneWay").click
      end

      def close
        # browser.close
      end
    end
  end
end
