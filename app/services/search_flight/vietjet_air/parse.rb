module SearchFlight
  module VietjetAir
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
          service_fee: 0
        }
        @adult = params[:adult]
        @child = params[:child]
        @infant = params[:infant]
      end

      def call
        if is_round_trip
          {
            depart_flights: get_flights("#toDepDiv .FlightsGrid tr[id*=gridTravel]"),
            return_flights: get_flights("#toRetDiv .FlightsGrid tr[id*=gridTravel]")
          }
        else
          {
            depart_flights: get_flights(".FlightsGrid tr[id*=gridTravel]")
          }
        end
      end

      def get_flights(selector)
        flights = []
        flights_table = html_content.search(selector)

        plane_category = PlaneCategory.find_by(category: :vietjet_air)

        flights_table.each do |flight_row|
          price_web = price_web(flight_row)
          if price_web
            price_adult = calculate_price(price_web, fare_formula_adult)
            price_child = calculate_price(price_web, fare_formula_child)
            price_infant = calculate_price(price_web, fare_formula_infant)

            flights << {
              plane_category_id: plane_category.id,
              airline_type: PlaneCategory.categories[:vietjet_air],
              code_flight: flight_code(flight_row),
              time_depart: from_time(flight_row),
              time_arrive: to_time(flight_row),
              price_web: price_web,
              price_adult: price_adult,
              price_child: price_child,
              price_infant: price_infant,
              price_total: price_total(price_adult, price_child, price_infant)
            }
          end
        end

        flights
      end

      private
        def flight_code(flight_row)
          flight_row.at_css('span[class*=airline]').text
        end

        def from_time(flight_row)
          flight_row.at_css('.SegInfo:nth-child(2)').text.match(/\d{1,2}:\d{1,2}/)[0]
        end

        def to_time(flight_row)
          flight_row.at_css('.SegInfo:nth-child(3)').text.match(/\d{1,2}:\d{1,2}/)[0]
        end

        def price_web(flight_row)
          price = nil
          td_prices = flight_row.css('.FaresGrid td')

          td_prices.each do |td_price|
            unless td_price.text.gsub(/[^\d]/, '').empty?
              price = td_price.text.gsub(/[^\d]/, '').to_i
              break
            end
          end

          price
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
