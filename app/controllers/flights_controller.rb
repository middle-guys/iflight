class FlightsController < ApplicationController
  def index
  	@alert = Alert.new
  	@ori_airport_id = params["ori_airport_id"]
  	@des_airport_id = params["des_airport_id"]
  	@from_date = params["from_date"]
  	@to_date = params["to_date"]
  end
end
