module BookFlight
  class Base
    def initialize
    end

    def call
      params = {
        itinerary: {
          category: "OW",
          ori_airport: {
            code: "SGN",
            name: "Hồ Chí Minh",
            name_unsigned: "Ho Chi Minh",
            short_name: "HCM",
            is_domestic: true
          },
          des_airport: {
            code: "HAN",
            name: "Hà Nội",
            name_unsigned: "Ha Noi",
            short_name: "HN",
            is_domestic: true
          },
          depart_date: "16/08/2016",
          return_date: "17/08/2016",
          adult_num: 2,
          child_num: 2,
          infant_num: 2
        },
        depart_flight: {
          airline_type: "jetstar",
          flight_code: "VJ184",
          from_time: "9:20",
          to_time: "10:40",
          price_no_fee: 799000,
          price_adult: 1081000,
          price_child: 1041000,
          price_infant: 150000,
          price_total: 1081000
        },
        return_flight: {
          airline_type: "jetstar",
          flight_code: "VJ175",
          from_time: "9:35",
          to_time: "10:55",
          price_no_fee: 900000,
          price_adult: 652000,
          price_child: 612000,
          price_infant: 150000,
          price_total: 652000
        },
        contact: {
          full_name: "Le Do Na",
          gender: 1,
          phone: "0933554440",
          email: "ledona@gmail.com"
        },
        passengers: [
          {
            full_name: "Nguyen Van Tien",
            category: 1,
            gender: 1,
            luggage_depart: 0,
            luggage_return: 30
          },
          {
            full_name: "Nguyen Thi Lien",
            category: 1,
            gender: 2,
            luggage_depart: 15,
            luggage_return: 35
          },
          {
            full_name: "Nguyen Tien Len",
            category: 2,
            gender: 1,
            luggage_depart: 20,
            luggage_return: 40
          },
          {
            full_name: "Nguyen Ngoc Nhi",
            category: 2,
            gender: 2,
            luggage_depart: 25,
            luggage_return: 0
          },
          {
            full_name: "Nguyen Tien Dat",
            category: 3,
            gender: 1,
            luggage_depart: 0,
            luggage_return: 0,
            dob: "31/08/2014"
          },
          {
            full_name: "Nguyen Ngan Khanh",
            category: 3,
            gender: 2,
            luggage_depart: 0,
            luggage_return: 0,
            dob: "31/03/2015"
          }
        ],
        price_luggage_depart: 80000,
        price_luggage_return: 80000
      }

      # BookFlight::Jetstar::Book.new(params).call
      BookFlight::VietjetAir::Book.new(params).call
    end
  end
end
