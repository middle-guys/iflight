class BookingJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    # params = {
    #   itinerary: {
    #     category: "OW",
    #     ori_airport: {
    #       code: "SGN",
    #       name: "Hồ Chí Minh",
    #       name_unsigned: "Ho Chi Minh",
    #       short_name: "HCM",
    #       is_domestic: true
    #     },
    #     des_airport: {
    #       code: "HAN",
    #       name: "Hà Nội",
    #       name_unsigned: "Ha Noi",
    #       short_name: "HN",
    #       is_domestic: true
    #     },
    #     depart_date: "20/08/2016",
    #     return_date: "21/08/2016",
    #     adult_num: 2,
    #     child_num: 2,
    #     infant_num: 2
    #   },
    #   depart_flight: {
    #     airline_type: "vietjet_air",
    #     flight_code: "VJ188",
    #     from_time: "9:20",
    #     to_time: "10:40",
    #     price_no_fee: 900000,
    #     price_adult: 1081000,
    #     price_child: 1041000,
    #     price_infant: 150000,
    #     price_total: 1081000
    #   },
    #   return_flight: {
    #     airline_type: "jetstar",
    #     flight_code: "BL 781",
    #     from_time: "9:35",
    #     to_time: "10:55",
    #     price_no_fee: 1020000,
    #     price_adult: 652000,
    #     price_child: 612000,
    #     price_infant: 150000,
    #     price_total: 652000
    #   },
    #   contact: {
    #     full_name: "Le Do Na",
    #     gender: 1,
    #     phone: "0933554440",
    #     email: "ledona@gmail.com"
    #   },
    #   passengers: [
    #     {
    #       full_name: "Nguyen Van Tien",
    #       category: 1,
    #       gender: 1,
    #       luggage_depart: 0,
    #       luggage_return: 30
    #     },
    #     {
    #       full_name: "Nguyen Thi Lien",
    #       category: 1,
    #       gender: 2,
    #       luggage_depart: 15,
    #       luggage_return: 35
    #     },
    #     {
    #       full_name: "Nguyen Tien Len",
    #       category: 2,
    #       gender: 1,
    #       luggage_depart: 20,
    #       luggage_return: 40
    #     },
    #     {
    #       full_name: "Nguyen Ngoc Nhi",
    #       category: 2,
    #       gender: 2,
    #       luggage_depart: 25,
    #       luggage_return: 0
    #     },
    #     {
    #       full_name: "Nguyen Tien Dat",
    #       category: 3,
    #       gender: 1,
    #       luggage_depart: 0,
    #       luggage_return: 0,
    #       dob: "31/08/2014"
    #     },
    #     {
    #       full_name: "Nguyen Ngan Khanh",
    #       category: 3,
    #       gender: 2,
    #       luggage_depart: 0,
    #       luggage_return: 0,
    #       dob: "31/03/2015"
    #     }
    #   ],
    #   price_luggage_depart: 80000,
    #   price_luggage_return: 80000
    # }

    order = Order.find(order_id)
    params = booking_params(order)

    p "start booking job"
    data = BookFlight::Base.new(params).call
    p "end booking job"

    if params[:itinerary][:category] == "OW"
      if reservation_valid?(data[:depart_reservation])
        order.reserving!
        order.depart_flight.update(code_book: data[:depart_reservation][:reservation_code])
        OrderMailer.receipt(order).deliver_later
        Sms::SmsSender.new(order).send
      else
        p data[:depart_reservation]
        order.failed!
        OrderMailer.booking_failed(order).deliver_later
      end
    else
      if reservation_valid?(data[:depart_reservation]) && reservation_valid?(data[:return_reservation])
        order.reserving!
        order.depart_flight.update(code_book: data[:depart_reservation][:reservation_code])
        order.return_flight.update(code_book: data[:return_reservation][:reservation_code])
        OrderMailer.receipt(order).deliver_later
        Sms::SmsSender.new(order).send
      else
        p reservation_valid?(data[:depart_reservation])
        p reservation_valid?(data[:return_reservation])
        order.failed!
        OrderMailer.booking_failed(order).deliver_later
      end
    end
    ActiveRecord::Base.clear_active_connections!
  end

  def reservation_valid?(reservation)
    reservation != 404 && reservation != 403
  end

  def booking_params(order)
      depart_flight = order.flights.where(category: :depart).first

      data = {
        itinerary: {
          category: "OW",
          ori_airport: {
            code: order.ori_airport.code
          },
          des_airport: {
            code: order.des_airport.code
          },
          depart_date: order.date_depart.to_s,
          adult_num: order.adult,
          child_num: order.child,
          infant_num: order.infant
        },
        depart_flight: {
          airline_type: depart_flight.plane_category.category.to_s,
          flight_code: depart_flight.code_flight,
          price_no_fee: depart_flight.price_web
        },
        contact: {
          full_name: order.contact_name,
          gender: order.contact_gender == "male" ? 1 : 2,
          phone: order.contact_phone,
          email: order.contact_email
        },
        passengers: []
      }

      order.passengers.each do |passenger|
        data[:passengers] << {
          full_name: passenger.name,
          category: passenger.adult? ? 1 : (passenger.child? ? 2 : 3),
          gender: passenger.male? ? 1 : 2,
          luggage_depart: passenger.depart_lug_weight.to_i,
          luggage_return: passenger.return_lug_weight.to_i,
          dob: passenger.dob
        }
      end

      if order.round_trip?
        return_flight = order.flights.where(category: :return).first
        data[:itinerary][:category] = "RT"
        data[:itinerary][:return_date] = order.date_return.to_s
        data[:return_flight] = {
          airline_type: return_flight.plane_category.category.to_s,
          flight_code: return_flight.code_flight,
          price_no_fee: return_flight.price_web
        }
      end

      data
    end
end
