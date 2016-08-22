require "flight_formulas"

class OrdersController < ApplicationController
  include FlightFormulas

  def new
    @alert = Alert.new
    @ori_airport_id = params["ori_airport_id"]
    @des_airport_id = params["des_airport_id"]
    @date_depart = params["date_depart"]
    @date_return = params["date_return"]
    @trip_type = params["itinerary_type"]

    @uuid = SecureRandom.uuid
    @ori_airport = Airport.find(params[:ori_airport_id])
    @des_airport = Airport.find(params[:des_airport_id])
    @date_depart = params[:date_depart]
    @date_return = params[:date_return]
    @adult = params[:adult_num].to_i
    @child = params[:child_num].to_i
    @infant = params[:infant_num].to_i
    @step_number = 2

    @order = Order.new
    if round_trip?(params[:itinerary_type])
      @order.category = :round_trip
      @is_round_trip = true
    else
      @order.category = :one_way
      @is_round_trip = false
    end

    pax_no = 1
    @adult.times do |i|
      passenger = @order.passengers.build
      passenger.category = :adult
      passenger.no = pax_no
      pax_no += 1
    end
    @child.times do |i|
      passenger = @order.passengers.build
      passenger.category = :child
      passenger.no = pax_no
      pax_no += 1
    end
    @infant.times do |i|
      passenger = @order.passengers.build
      passenger.category = :infant
      passenger.no = pax_no
      pax_no += 1
    end

    flight_depart = @order.flights.build
    flight_depart.category = :depart
    if round_trip?(params[:itinerary_type])
      flight_return = @order.flights.build
      flight_return.category = :return
    end

    CrawlFlightsJob.perform_later(
      uuid: @uuid,
      ori_code: @ori_airport.code,
      des_code: @des_airport.code,
      date_depart: @date_depart,
      date_return: @date_return,
      adult: @adult,
      child: @child,
      infant: @infant,
      round_type: params[:itinerary_type]
    )
  end

  def create
    @order = CreateOrderService.new.new_order(order_params, current_user)
    if @order.save
      BookingJob.perform_later(booking_params, @order.id)
      redirect_to action: "confirmation", id: @order.id
    else
      flash[:error] = "Something wrongs ! #{@order.errors.full_messages.to_sentence}"
      redirect_to :back
    end
  end

  def confirmation
    @order = Order.find(params[:id])
    @order.flights.each do |flight|
      @flight_depart = flight if flight.depart?
      @flight_return = flight if flight.return?
    end
  end

  private
    def order_params
      params.require(:order).permit(
        :category, :date_depart, :date_return, :contact_name, :contact_phone, :contact_email, :contact_gender,
        :adult, :child, :infant, :ori_airport_id, :des_airport_id, :price_total,
        passengers_attributes: [:name, :gender, :category, :depart_lug_weight, :return_lug_weight, :dob],
        flights_attributes: [:category, :plane_category_id, :code_flight, :time_depart, :time_arrive, :price_web, :price_total])
    end

    def booking_params
      depart_flight = @order.flights.where(category: :depart).first

      data = {
        itinerary: {
          category: "OW",
          ori_airport: {
            code: @order.ori_airport.code
          },
          des_airport: {
            code: @order.des_airport.code
          },
          depart_date: @order.date_depart.to_s,
          adult_num: @order.adult,
          child_num: @order.child,
          infant_num: @order.infant
        },
        depart_flight: {
          airline_type: depart_flight.plane_category.category.to_s,
          flight_code: depart_flight.code_flight,
          price_no_fee: depart_flight.price_web
        },
        contact: {
          full_name: @order.contact_name,
          gender: @order.contact_gender == "male" ? 1 : 2,
          phone: @order.contact_phone,
          email: @order.contact_email
        },
        passengers: []
      }

      @order.passengers.each do |passenger|
        data[:passengers] << {
          full_name: passenger.name,
          category: passenger.adult? ? 1 : (passenger.child? ? 2 : 3),
          gender: passenger.male? ? 1 : 2,
          luggage_depart: passenger.depart_lug_weight.to_i,
          luggage_return: passenger.return_lug_weight.to_i,
          dob: passenger.dob
        }
      end

      if @order.round_trip?
        return_flight = @order.flights.where(category: :return).first
        data[:itinerary][:category] = "RT"
        data[:itinerary][:return_date] = @order.date_return.to_s
        data[:return_flight] = {
          airline_type: return_flight.plane_category.category.to_s,
          flight_code: return_flight.code_flight,
          price_no_fee: return_flight.price_web
        }
      end

      data
    end
end
