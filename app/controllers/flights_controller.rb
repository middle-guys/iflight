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
    ShareFlightJob.perform_later(
      sender_name: share_flight_params[:sender_name],
      receiver_email: share_flight_params[:receiver_email],
      ori_airport_id: share_flight_params[:ori_airport_id],
      des_airport_id: share_flight_params[:des_airport_id],
      date_depart: share_flight_params[:date_depart],
      plane_category_id: share_flight_params[:flight][:plane_category_id],
      code_flight: share_flight_params[:flight][:code_flight],
      time_depart: share_flight_params[:flight][:time_depart],
      time_arrive: share_flight_params[:flight][:time_arrive],
      price_web: share_flight_params[:flight][:price_web].to_i,
      price_adult: share_flight_params[:flight][:price_adult].to_i
    )
    head :ok
  end

  private
    def share_flight_params
      params.permit(:sender_name, :receiver_email, :ori_airport_id, :des_airport_id, :date_depart,
        flight: [:plane_category_id, :code_flight, :time_depart, :time_arrive, :price_web, :price_adult])
    end
end
