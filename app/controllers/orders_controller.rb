class OrdersController < ApplicationController
  def new
    @uuid = SecureRandom.uuid
    @ori_airport = Airport.find(params[:ori_airport_id])
    @des_airport = Airport.find(params[:des_airport_id])
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    @adult = params[:adult_num].to_i
    @child = params[:child_num].to_i
    @infant = params[:infant_num].to_i

    @order = Order.new
    if params[:itinerary_type] == "RT"
      @order.category = :round_trip
    else
      @order.category = :one_way
    end

    pax_no = 1
    @adult.times do |i|
      passenger = @order.passengers.new
      passenger.category = :adult
      passenger.no = pax_no
      pax_no += 1
    end
    @child.times do |i|
      passenger = @order.passengers.new
      passenger.category = :child
      passenger.no = pax_no
      pax_no += 1
    end
    @infant.times do |i|
      passenger = @order.passengers.new
      passenger.category = :infant
      passenger.no = pax_no
      pax_no += 1
    end

    flight_depart = @order.flights.new
    flight_depart.category = :depart
    if params[:itinerary_type] == "RT"
      flight_return = @order.flights.new
      flight_return.category = :return      
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

  def create
    byebug
  end

  def show
  end

  private
    def order_params
      params.require(:order).permit(:category, :from_date, :to_date, :contact_name, :contact_phone, :contact_email, :contact_gender, :adult, :child, :infant, :ori_airport_id, :des_airport_id, passengers_attributes: [:name, :gender, :category, :depart_lug_weight, :return_lug_weight, :dob])
    end
end
