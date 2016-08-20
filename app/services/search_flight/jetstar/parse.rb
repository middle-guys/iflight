module SearchFlight
  module Jetstar
    class Parse
      attr_accessor :html_content, :is_round_trip
      attr_reader :fare_formula_adult, :fare_formula_child, :fare_formula_infant, :adult, :child, :infant

      def initialize(params)
        @html_content = params[:content]
        @is_round_trip = params[:is_round_trip]
        @fare_formula_adult = {
          percent_price_web: 100,
          percent_vat: 10,
          service_fee: 190000
        }
        @fare_formula_child = {
          percent_price_web: 100,
          percent_vat: 10,
          service_fee: 150000
        }
        @fare_formula_infant = {
          percent_price_web: 0,
          percent_vat: 10,
          service_fee: 150000
        }
        @adult = params[:adult]
        @child = params[:child]
        @infant = params[:infant]
      end

      def call
        if is_round_trip
          {
            depart_flights: get_flights("div.fare-picker.depart div.fares table.domestic tbody tr:not(.business-options):not(.starter-options)"),
            return_flights: get_flights("div.fare-picker.return div.fares table.domestic tbody tr:not(.business-options):not(.starter-options)")
          }
        else
          {
            depart_flights: get_flights("div.fares table.domestic tbody tr:not(.business-options):not(.starter-options)")
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
                plane_category_id: PlaneCategory.find_by(category: :jetstar).id,
                airline_type: PlaneCategory.categories[:jetstar],
                code_flight: flight_code(flight_row),
                from_time: from_time(flight_row),
                to_time: to_time(flight_row),
                price_web: price_web,
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
          flight_row.at_css("span.flight-no").text.gsub(/\s+/, "")
        end

        def from_time(flight_row)
          flight_row.at_css("td:nth-child(1) strong").text.match(/\d{1,2}:\d{1,2}/)[0]
        end

        def to_time(flight_row)
          flight_row.at_css("td:nth-child(2) strong").text.match(/\d{1,2}:\d{1,2}/)[0]
        end

        def price_web(flight_row)
          price = nil

          price_str = price_starter(flight_row)
          if price_str.nil?
            price_str =  price_business(flight_row)
          end
          if !price_str.nil? && !price_str.empty?
            price = price_str.to_i
          end

          price
        end

        def price_starter(flight_row)
          price_result = nil

          price = flight_row.css("td:nth-child(4) label")
          if price.present?
            price_result = price.text.gsub(/[^\d]/, "")
          end
          price_result
        end

        def price_business(flight_row)
          price_result = nil

          price = flight_row.css("td:nth-child(5) label")
          if !price.nil?
            price_result = price.text.gsub(/[^\d]/, "")
          end

          price_result
        end

        def flight_direct?(flight_row)
          flight_row.at_css('.stops').present? && flight_row.at_css('.stops').text == "Bay thẳng"
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
