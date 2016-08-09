module SearchFlight
  module VietnamAirline
    class Parse
      attr_accessor :html_content, :is_round_trip

      def initialize(content, is_round_trip)
        @html_content = Nokogiri::HTML(content)
        @is_round_trip = is_round_trip
      end

      def call
        if is_round_trip
          {
            depart_flights: get_flights("#dtcontainer-outbounds tbody tr"),
            return_flights: get_flights("#dtcontainer-inbounds tbody tr")
          }
        else
          {
            depart_flights: get_flights("#dtcontainer-both tbody tr")
          }
        end
      end

      def get_flights(selector)
        flights = []
        flights_table = html_content.css(selector)

        flights_table.each do |flight_row|
          if flight_direct?(flight_row)
            price_web = price_web(flight_row)
            if price_web
              flights << {
                airline_type: 1,
                flight_code: flight_code(flight_row),
                from_time: from_time(flight_row),
                to_time: to_time(flight_row),
                price_web: price_web(flight_row)
              }
            end
          end
        end

        flights
      end

      private
        def flight_code(flight_row)
          flight_row.at_css(".flightDetails-link .flight-number").text
        end

        def from_time(flight_row)
          flight_row.at_css(".departureDate .wasTranslated").text
        end

        def to_time(flight_row)
          flight_row.at_css(".arrivalDate .wasTranslated").text
        end

        def price_web(flight_row)
          price = nil
          prices = flight_row.css(".prices-amount")

          if prices.count > 0
            price_str = prices.last.text.gsub(/[^\d]/, "")

            price = price_str.to_i if price_str.present?
          end

          price
        end

        def flight_direct?(flight_row)
          number_stops = flight_row.at_css(".stops")
          number_stops.present? && number_stops.text.to_i == 0
        end
    end
  end
end
