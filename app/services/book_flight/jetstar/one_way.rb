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
        select_price_page = search

        selected_price_element = get_selected_price_element(select_price_page, "depart", depart_flight[:flight_code], depart_flight[:price_no_fee])

        return 404 unless selected_price_element

        fill_info_page = select_price(selected_price_element)

        checkout_page = fill_info

        reservation_page = checkout

        {
          reservation_code: reservation_page.at("#booking-data booking")["pnr"],
          holding_date: reservation_page.at("#booking-data booking")["holddateutc"]
        }
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
        body = {
          "__EVENTTARGET" => "AgentControlGroupPassengerView$ButtonSubmit",
          "__EVENTARGUMENT" => "",
          "__VIEWSTATE" => "",
          "pageToken" => "",
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

        agent.post(
          "https://agenthub.jetstar.com/AgentPassenger.aspx",
          body
        )
      end

      def checkout
        agent.post(
          "https://agenthub.jetstar.com/AgentPay.aspx",
          {
            "__EVENTTARGET" => "",
            "__EVENTARGUMENT" => "",
            "__VIEWSTATE" => "",
            "pageToken" => "",
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$PaymentMethodDropDown" => "ExternalAccount-HOLD",
            "card_number1" => "",
            "card_number2" => "",
            "card_number3" => "",
            "card_number4" => "",
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$TextBoxCC__AccountHolderName" => "",
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$DropDownListEXPDAT_Month" => Time.now.month,
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$DropDownListEXPDAT_Year" => Time.now.year,
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$TextBoxCC__VerificationCode" => "",
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$TextBoxACCTNO" => "",
            "inlineDCCAjaxSucceeded" => "false",
            "ControlGroupAgentPayView$PaymentSectionAgentPayView$UpdatePanelAgentPayView$PaymentInputAgentPayView$TextBoxVoucherAccount_VO_ACCTNO" => "",
            "ControlGroupAgentPayView$AgreementInputAgentPayView$CheckBoxAgreement" => "on",
            "summary-amount-total" => "NaN",
            "ControlGroupAgentPayView$ButtonSubmit" => ""
          }
        )
        agent.get "https://agenthub.jetstar.com/Wait.aspx"
        agent.get "https://agenthub.jetstar.com/Wait.aspx"

        agent.get "https://agenthub.jetstar.com/htl2-Itinerary.aspx"
      end
    end
  end
end
