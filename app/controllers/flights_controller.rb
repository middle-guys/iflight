class FlightsController < ApplicationController
  def index
    @uuid = SecureRandom.uuid
    @ori_airport = Airport.find(params[:ori_airport_id])
    @des_airport = Airport.find(params[:des_airport_id])
    @from_date = params[:from_date]
    @to_date = params[:to_date]

    @order = Order.new
    if params[:itinerary_type] == "RT"
      @order.category = :round_trip
    else
      @order.category = :one_way
    end

    pax_no = 1
    params[:adult_num].to_i.times do |i|
      passenger = @order.passengers.new
      passenger.category = :adult
      passenger.no = pax_no
      pax_no += 1
    end
    params[:child_num].to_i.times do |i|
      passenger = @order.passengers.new
      passenger.category = :child
      passenger.no = pax_no
      pax_no += 1
    end
    params[:infant_num].to_i.times do |i|
      passenger = @order.passengers.new
      passenger.category = :infant
      passenger.no = pax_no
      pax_no += 1
    end

    CrawlFlightsJob.perform_later(
      uuid: @uuid,
      ori_code: "SGN",
      des_code: "HAN",
      depart_date: "14/08/2016",
      adult: 2,
      child: 1,
      infant: 1,
      return_date: "15/08/2016",
      round_type: "RT"
    )
  end
end
