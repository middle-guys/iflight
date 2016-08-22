module BookFlight
  class Base
    attr_accessor :params
    def initialize(params)
      @params = params
    end

    def call
      depart_reservation = nil
      return_reservation = nil

      if params[:itinerary][:category] == "OW" || params[:depart_flight][:airline_type] == params[:return_flight][:airline_type]
        if vietnam_airlines?(params[:depart_flight][:airline_type])
          depart_reservation = BookFlight::VietnamAirlines::Book.new(params).call
        elsif jetstar?(params[:depart_flight][:airline_type])
          depart_reservation = BookFlight::Jetstar::Book.new(params).call
        elsif vietjet_air?(params[:depart_flight][:airline_type])
          depart_reservation = BookFlight::VietjetAir::Book.new(params).call
        end
      else
        depart_params = Marshal.load(Marshal.dump(params))
        return_params = Marshal.load(Marshal.dump(params))

        depart_params[:itinerary][:category] = "OW"

        return_params[:itinerary][:category] = "OW"
        return_params[:itinerary][:ori_airport] = params[:itinerary][:des_airport]
        return_params[:itinerary][:des_airport] = params[:itinerary][:ori_airport]
        return_params[:depart_flight] = params[:return_flight]
        return_params[:itinerary][:depart_date] = params[:itinerary][:return_date]
        return_params[:passengers].each_with_index do |passenger, index|
          passenger[:luggage_depart] = params[:passengers][index][:luggage_return]
        end

        if vietnam_airlines?(depart_params[:depart_flight][:airline_type])
          depart_reservation = BookFlight::VietnamAirlines::Book.new(depart_params).call
        elsif jetstar?(depart_params[:depart_flight][:airline_type])
          depart_reservation = BookFlight::Jetstar::Book.new(depart_params).call
        elsif vietjet_air?(depart_params[:depart_flight][:airline_type])
          depart_reservation = BookFlight::VietjetAir::Book.new(depart_params).call
        end

        if vietnam_airlines?(return_params[:depart_flight][:airline_type])
          return_reservation = BookFlight::VietnamAirlines::Book.new(return_params).call
        elsif jetstar?(return_params[:depart_flight][:airline_type])
          return_reservation = BookFlight::Jetstar::Book.new(return_params).call
        elsif vietjet_air?(return_params[:depart_flight][:airline_type])
          return_reservation = BookFlight::VietjetAir::Book.new(return_params).call
        end
      end

      if params[:itinerary][:category] == "RT" && params[:depart_flight][:airline_type] == params[:return_flight][:airline_type]
        return_reservation = depart_reservation
      end

      {
        depart_reservation: depart_reservation,
        return_reservation: return_reservation
      }
    end

    def vietnam_airlines?(airline_type)
      airline_type == PlaneCategory.categories[:vietnam_airlines]
    end

    def vietjet_air?(airline_type)
      airline_type == PlaneCategory.categories[:vietjet_air]
    end

    def jetstar?(airline_type)
      airline_type == PlaneCategory.categories[:jetstar]
    end
  end
end
