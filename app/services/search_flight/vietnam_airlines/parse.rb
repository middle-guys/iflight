module SearchFlight
  module VietnamAirlines
    class Parse
      attr_accessor :html_content, :is_round_trip
      attr_reader :fare_formula_adult, :fare_formula_child, :fare_formula_infant, :adult, :child, :infant

      def initialize(params)
        @html_content = params[:content]
        @is_round_trip = params[:is_round_trip]
        @fare_formula_adult = {
          percent_price_web: 100,
          percent_vat: 10,
          service_fee: 80000
        }
        @fare_formula_child = {
          percent_price_web: 75,
          percent_vat: 10,
          service_fee: 40000
        }
        @fare_formula_infant = {
          percent_price_web: 10,
          percent_vat: 10,
          service_fee: 0
        }
        @adult = params[:adult]
        @child = params[:child]
        @infant = params[:infant]
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
        flights_table = html_content.search(selector)

        flights_table.each do |flight_row|
          if flight_direct?(flight_row)
            price_web = price_web(flight_row)
            if price_web
              price_adult = calculate_price(price_web, fare_formula_adult)
              price_child = calculate_price(price_web, fare_formula_child)
              price_infant = calculate_price(price_web, fare_formula_infant)

              flights << {
                airline_type: 1,
                flight_code: flight_code(flight_row),
                from_time: from_time(flight_row),
                to_time: to_time(flight_row),
                price_no_fee: price_web,
                price_adult: price_adult,
                price_child: price_child,
                price_infant: price_infant,
                price_total: price_total(price_adult, price_child, price_infant)
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

        def calculate_price(price_web, fare_formula)
          price = price_web * fare_formula[:percent_price_web] / 100
          price += price * fare_formula[:percent_vat] / 100 + fare_formula[:service_fee]
        end

        def price_total(price_adult, price_child, price_infant)
          price_adult * adult + price_child * child + price_infant * infant
        end
    end
  end
end
