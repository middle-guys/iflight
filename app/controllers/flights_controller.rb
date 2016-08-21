class FlightsController < ApplicationController
  def index
  	@alert = Alert.new
  	@ori_airport_id = params["ori_airport_id"]
  	@des_airport_id = params["des_airport_id"]
  	@from_date = params["from_date"]
  	@to_date = params["to_date"]
  	@trip_type = params["itinerary_type"]
  end

  def share
    byebug
    head :ok
  end

  private
    def share_flight_params
      params.permit(:sender_name, :receiver_email, :ori_airport, :des_airport, :date_depart,
        flight: [:plane_category_id, :code_flight, :time_depart, :time_arrive, :price_web, :price_adult])
    end
end
