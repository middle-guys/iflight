module BookFlight
  module Jetstar
    class OneWay < JetstarFormulas
      attr_accessor :agent, :itinerary, :depart_flight, :passengers, :contact, :adult_passengers, :child_passengers, :infant_passengers

      def initialize(agent, params)
        @agent = agent
        @itinerary = params[:itinerary]
        @depart_flight = params[:depart_flight]
        @passengers = params[:passengers]
        @contact = params[:contact]
        @adult_passengers = passengers.select{ |x| x[:category] == 1 }
        @child_passengers = passengers.select{ |x| x[:category] == 2 }
        @infant_passengers = passengers.select{ |x| x[:category] == 3 }
      end

      def call
        search_page = search

        selected_price_element = get_selected_price_element(search_page, "depart", depart_flight[:flight_code], depart_flight[:price_no_fee])

        return 404 unless selected_price_element

        fill_info_page = select_price(selected_price_element)

        checkout_page = fill_info

        File.open("out.html", "wb") do |f|
          f.write checkout_page.body
          f.close
        end
      end

      def search
        agent.post(
          "https://agenthub.jetstar.com/TradeSalesHome.aspx",
          {
            "__EVENTTARGET" => "",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$RadioButtonMarketStructure" => "OneWay",
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketOrigin1" => itinerary[:ori_airport][:code],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextBoxMarketDestination1" => itinerary[:des_airport][:code],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$TextboxDepartureDate1" => format_date(itinerary[:depart_date]),
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_ADT" => itinerary[:adult_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_CHD" => itinerary[:child_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListPassengerType_INFANT" => itinerary[:infant_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_ADT" => itinerary[:adult_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_CHD" => itinerary[:child_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$DropDownListMultiPassengerType_INFANT" => itinerary[:infant_num],
            "ControlGroupTradeSalesHomeView$AvailabilitySearchInputTradeSalesHomeView$ButtonSubmit" => ""
          }
        )
      end

      def select_price(flight_price_selection)
        body = {
          "__EVENTTARGET" => "ControlGroupAgentSelectView$ButtonSubmit",
          "__EVENTARGUMENT" => "",
          "__VIEWSTATE" => "",
          "pageToken" => "",
          "bannerFileName" => "",
          "baggage-selection-toggler" => "on",
          "marketstructure" => "OneWay",
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$HiddenFieldTabIndex1" => 2,
          "ControlGroupAgentSelectView$AvailabilityInputAgentSelectView$market1" => flight_price_selection.at("input")["value"],
          "AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0" => "BG15"
        }

        (itinerary[:adult_num] + itinerary[:child_num]).times do |index|
          body["AgentAdditionalBaggagePassengerView$AdditionalBaggageDropDownListJourney0Pax#{index}"] = luggage(passengers[index][:luggage_depart])
        end

        agent.post(
          "https://agenthub.jetstar.com/AgentSelect.aspx",
          body
        )
      end

      def fill_info
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListTitle_1:MR
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_1:Nguyen
        # default-value-lastname-1:Họ
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_1:Van Tien
        # default-value-firstname-1:Tên đệm & Tên
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_1:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_1:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_1:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_1:1
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxProgramNumber_1:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListProgram_1:QF
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListTitle_3:MRS
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_3:Nguyen
        # default-value-lastname-2:Họ
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_3:Thi Lien
        # default-value-firstname-2:Tên đệm & Tên
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_3:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_3:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_3:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_3:2
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxProgramNumber_3:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListProgram_3:QF
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListTitle_5:MISS
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_5:Nguyen
        # default-value-lastname-3:Họ
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_5:Ngoc Nhi
        # default-value-firstname-3:Tên đệm & Tên
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_5:31
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_5:3
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_5:2008
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_5:2
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxProgramNumber_5:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListProgram_5:QF
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListTitle_6:MSTR
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_6:Nguyen
        # default-value-lastname-4:Họ
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_6:Tien Len
        # default-value-firstname-4:Tên đệm & Tên
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_6:31
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_6:12
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_6:2006
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_6:1
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxProgramNumber_6:
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListProgram_6:QF
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_2:Nguyen
        # default-value-lastname-5:Họ
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_2:Ngan Khanh
        # default-value-firstname-5:Tên đệm & Tên
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListAssign_2:1
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_2:31
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_2:3
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_2:2015
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_2:2
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_4:Nguyen
        # default-value-lastname-6:Họ
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_4:Tien Dat
        # default-value-firstname-6:Tên đệm & Tên
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListAssign_4:1
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_4:31
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_4:10
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_4:2014
        # AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_4:1

        body = {
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$DropDownListTitle" => title_adult(contact[:gender]),
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxLastName" => last_name(contact[:full_name]),
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxFirstName" => first_name(contact[:full_name]),
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$DropDownListWorkPhoneCountryCode" => "VN",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxWorkPhone" => contact[:phone],
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxJahEmailAddress" => contact[:email],
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxEmailAddress" => "Info@baogiatran.vn",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxPostalCode" => "084",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxCity" => "TAN BINH",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxAddressLine1" => "379 NGUYEN TRONG TUYEN",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxAddressLine2" => "",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$TextBoxCompanyName" => "CONG TY TNHH TM DV DU LICH BAO GIA TRAN",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$DropDownListCountry" => "VN",
          "AgentControlGroupPassengerView$AgentContactInputViewPassengerView$DropDownListCountryCode" => "VN",
          "AgentControlGroupPassengerView$AgentItineraryDistributionInputPassengerView$Distribution" => "2"
        }

        (itinerary[:adult_num] + itinerary[:child_num]).times do |index|
          body["AgentControlGroupPassengerView$AgentUnitMapSeatsView$HiddenEquipmentConfiguration_0_PassengerNumber_#{index}"] = ""
        end

        current_index_adult = 0
        infant_num_tmp = itinerary[:infant_num]

        itinerary[:adult_num].times do |index|
          if itinerary[:infant_num] > 0 && infant_num_tmp > 0
            current_index_adult = 2 * index + 1
            infant_num_tmp -= 1
          end

          current_passenger = adult_passengers[index]

          body["default-value-lastname-#{current_index_adult}"] = "Họ"
          body["default-value-firstname-#{current_index_adult}"] = "Tên đệm & Tên"
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListTitle_#{current_index_adult}"] = title_adult(current_passenger[:gender])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_#{current_index_adult}"] = last_name(current_passenger[:full_name])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_#{current_index_adult}"] = first_name(current_passenger[:full_name])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_#{current_index_adult}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_#{current_index_adult}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_#{current_index_adult}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_#{current_index_adult}"] = current_passenger[:gender]
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxProgramNumber_#{current_index_adult}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListProgram_#{current_index_adult}"] = "QF"

          if itinerary[:infant_num] == 0
            current_index_adult += 1
          else
            if infant_num_tmp < 0
              current_index_adult += 1
            end
          end
        end

        itinerary[:infant_num].times do |index|
          current_index_infant = 2 * index + 2
          current_passenger = infant_passengers[index]

          body["default-value-lastname-#{current_index_infant}"] = "Họ"
          body["default-value-firstname-#{current_index_infant}"] = "Tên đệm & Tên"
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_#{current_index_infant}"] = last_name(current_passenger[:full_name])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_#{current_index_infant}"] = first_name(current_passenger[:full_name])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListAssign_#{current_index_infant}"] = index + 1
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_#{current_index_infant}"] = format_day(current_passenger[:dob])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_#{current_index_infant}"] = format_month(current_passenger[:dob])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_#{current_index_infant}"] = format_year(current_passenger[:dob])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_#{current_index_infant}"] = current_passenger[:gender]
        end

        itinerary[:child_num].times do |index|
          current_index_child = itinerary[:infant_num] + itinerary[:adult_num] + index + 1
          current_passenger = child_passengers[index]

          body["default-value-lastname-#{current_index_child}"] = "Họ"
          body["default-value-firstname-#{current_index_child}"] = "Tên đệm & Tên"
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListTitle_#{current_index_child}"] = title_child(current_passenger[:gender])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxLastName_#{current_index_child}"] = last_name(current_passenger[:full_name])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxFirstName_#{current_index_child}"] = first_name(current_passenger[:full_name])
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateDay_#{current_index_child}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateMonth_#{current_index_child}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListBirthDateYear_#{current_index_child}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListGender_#{current_index_child}"] = current_passenger[:gender]
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$TextBoxProgramNumber_#{current_index_child}"] = ""
          body["AgentControlGroupPassengerView$AgentPassengerInputViewPassengerView$DropDownListProgram_#{current_index_child}"] = "QF"
        end

        ap body
        agent.post(
          "https://agenthub.jetstar.com/AgentPassenger.aspx",
          body
        )
      end
    end
  end
end
