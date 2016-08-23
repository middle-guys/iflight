class BookingJob < ApplicationJob
  queue_as :default

  def perform(params, order_id)
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
    p "start booking job"
    order = Order.find(order_id)
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
end
