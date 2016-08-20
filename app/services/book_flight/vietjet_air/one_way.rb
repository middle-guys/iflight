module BookFlight
  module VietjetAir
    class OneWay < VietjetAirFormulas
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
        begin
          select_price_page = search

          selected_price_element = get_selected_price_element(select_price_page, "toDepDiv", depart_flight[:flight_code], depart_flight[:price_no_fee])

          return 404 unless selected_price_element

          fill_info_page = select_price(selected_price_element)

          pick_luggage_page = fill_info

          checkout_page = pick_luggage(pick_luggage_page)

          confirm_info_page = checkout

          process_page = confirm_info

          reservation_page = process

          {
            reservation_code: reservation_page.at("span.ResNumber").text,
            holding_date: get_holding_date(reservation_page.at("form h1:nth(2)").text)
          }
        rescue
          403
        end
        #reservation_code=>"36241020", :holding_date=>"Nếu không thanh toán, đến  19/08/2016 Fri 22:10 (GMT+7), đặt chỗ của bạn sẽ tự động bị hủy."
      end

      def search
        body = {
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "SesID" => "",
          "DebugID" => "10",
          "button" => "vfto",
          "dlstDepDate_Day" => format_day(itinerary[:depart_date]),
          "dlstDepDate_Month" => format_year_month(itinerary[:depart_date]),
          "dlstRetDate_Day" => format_day(itinerary[:depart_date]),
          "dlstRetDate_Month" => format_year_month(itinerary[:depart_date]),
          "lstDepDateRange" => "0",
          "lstRetDateRange" => "0",
          "chkRoundTrip" => "",
          "lstOrigAP" => itinerary[:ori_airport][:code],
          "lstDestAP" => itinerary[:des_airport][:code],
          "departure1" => format_date(itinerary[:depart_date]),
          "departTime1" => "0000",
          "departure2" => format_date(itinerary[:depart_date]),
          "departTime2" => "0000",
          "lstLvlService" => "1",
          "lstResCurrency" => "VND",
          "txtNumAdults" => itinerary[:adult_num],
          "txtNumChildren" => itinerary[:child_num],
          "txtNumInfants" => itinerary[:infant_num],
          "lstCompanyList" => "3184ƒCTY TNHH TM&DV DL BAO GIA TRAN (SUB 2)",
          "txtPONumber" => ""
        }

        agent.post(
          "https://agent.vietjetair.com/ViewFlights.aspx?lang=vi&st=sl&sesid=",
          body
        )
      end

      def select_price(flight_price_selection)
        agent.post(
          "https://agent.vietjetair.com//TravelOptions.aspx?lang=vi&st=sl&sesid=",
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "button" => "continue",
          "SesID" => "",
          "DebugID" => "10",
          "PN" => "",
          "RPN" => "",
          "gridTravelOptDep" => travel_info(flight_price_selection),
          "gridTravelOptRet" => travel_info(flight_price_selection)
        )
      end

      def fill_info
        body = {
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "SesID" => "",
          "DebugID" => "11",
          "button" => "continue",
          "txtPax1_City" => "Ho Chi Minh",
          "txtPax1_Ctry" => "234",
          "txtPax1_Prov" => "-1",
          "txtPax1_EMail" => contact[:email],
          "txtPax1_Phone1" => contact[:phone],
          "txtPax1_Phone2" => contact[:phone],
          "txtPax1_Addr1" => "8/24 Hoang Hoa Tham - Binh Thanh",
          "txtResNotes" => ""
        }

        itinerary[:adult_num].times do |index|
          current_index = index + 1
          current_adult = adult_passengers[index]

          body["txtPax#{current_index}_Gender"] = gender(current_adult[:gender])
          body["txtPax#{current_index}_LName"] = last_name(current_adult[:full_name])
          body["txtPax#{current_index}_FName"] = first_name(current_adult[:full_name])
          body["txtPax#{current_index}_DOB_Day"] = ""
          body["txtPax#{current_index}_DOB_Month"] = ""
          body["txtPax#{current_index}_DOB_Year"] = ""
          body["txtPax#{current_index}_Passport"] = ""
          body["dlstPax#{current_index}_PassportExpiry_Day"] = ""
          body["dlstPax#{current_index}_PassportExpiry_Month"] = ""
          body["lstPax#{current_index}_PassportCtry"] = ""
          body["txtPax#{current_index}_Nationality"] = ""
          body["hidPax#{current_index}_Search"] = "-1"

          current_infant = infant_passengers[index]
          if current_infant
            body["chkPax#{current_index}_Infant"] = "on"
            body["txtPax#{current_index}_Infant_DOB_Day"] = format_day(current_infant[:dob])
            body["txtPax#{current_index}_Infant_DOB_Month"] = format_month(current_infant[:dob])
            body["txtPax#{current_index}_Infant_DOB_Year"] = format_year(current_infant[:dob])
            body["txtPax#{current_index}_Infant_FName"] = last_name(current_infant[:full_name])
            body["txtPax#{current_index}_Infant_LName"] = first_name(current_infant[:full_name])
          else
            body["txtPax#{current_index}_Infant_DOB_Day"] = ""
            body["txtPax#{current_index}_Infant_DOB_Month"] = ""
            body["txtPax#{current_index}_Infant_DOB_Year"] = ""
            body["txtPax#{current_index}_Infant_FName"] = ""
            body["txtPax#{current_index}_Infant_LName"] = ""
          end
        end

        itinerary[:child_num].times do |index|
          current_index = itinerary[:adult_num] + index + 1
          current_child = child_passengers[index]

          body["txtPax#{current_index}_Gender"] = "C"
          body["txtPax#{current_index}_LName"] = last_name(current_child[:full_name])
          body["txtPax#{current_index}_FName"] = first_name(current_child[:full_name])
          body["txtPax#{current_index}_Phone1"] = ""
          body["txtPax#{current_index}_DOB_Day"] = ""
          body["txtPax#{current_index}_DOB_Month"] = ""
          body["txtPax#{current_index}_DOB_Year"] = ""
          body["txtPax#{current_index}_Passport"] = ""
          body["dlstPax#{current_index}_PassportExpiry_Day"] = ""
          body["dlstPax#{current_index}_PassportExpiry_Month"] = ""
          body["lstPax#{current_index}_PassportCtry"] = ""
          body["txtPax#{current_index}_Nationality"] = ""
          body["hidPax#{current_index}_Search"] = "-1"
        end

        agent.post(
          "https://agent.vietjetair.com/Details.aspx?lang=vi&st=sl&sesid=",
          body
        )
      end

      def pick_luggage(pick_luggage_page)
        body = {
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "SesID" => "",
          "DebugID" => "35",
          "button" => "continue",
          "m1th" => "2",
          "m1p" => "1",
          "ctrSeatAssM" => "1",
          "ctrSeatAssP" => itinerary[:adult_num] + itinerary[:child_num],
          "-1" => "-1",
          "shpsel" => "",
          "chkInsuranceNo" => "N"
        }

        list_select_elements = pick_luggage_page.search(".lstShopSelect")

        itinerary[:adult_num].times do |index|
          current_adult = adult_passengers[index]
          lst_pax_item = list_select_elements[index]
          current_luggage_index = luggage_index(current_adult[:luggage_depart])

          if current_adult[:luggage_depart] == 0
            body[lst_pax_item["name"]] = "-1"
          else
            option_pax_item = lst_pax_item.at("option:nth(#{current_luggage_index})")
            body[lst_pax_item["name"]] = option_pax_item["value"]
            body["hidPaxItem:#{option_pax_item['hidpaxitem']}"] = option_pax_item["hidpaxvalue"]
          end
        end

        itinerary[:child_num].times do |index|
          current_index = itinerary[:adult_num] + index
          current_child = child_passengers[index]
          lst_pax_item = list_select_elements[current_index]
          current_luggage_index = luggage_index(current_child[:luggage_depart])

          if current_child[:luggage_depart] == 0
            body[lst_pax_item["name"]] = "-1"
          else
            option_pax_item = lst_pax_item.at("option:nth(#{current_luggage_index})")
            body[lst_pax_item["name"]] = option_pax_item["value"]
            body["hidPaxItem:#{option_pax_item['hidpaxitem']}"] = option_pax_item["hidpaxvalue"]
          end
        end

        (itinerary[:adult_num] + itinerary[:child_num]).times do |index|
          current_index = index + 1

          body["m1p#{current_index}"] = ""
          body["m1p#{current_index}rpg"] = ""
          body["hidPaxItem:-#{current_index}:17:2:0"] = "2ƒNAƒ17ƒ2157808ƒ40000ƒFalseƒ3ƒBun XaoƒVJ175 - Ha NoiƒNAƒ2157808ƒ1ƒBun Xao Singaporeƒ40,000 VNDƒ40000ƒ4000.00ƒ0ƒ0"
          body["hidPaxItem:-#{current_index}:64:2:0"] = "2ƒNAƒ64ƒ2158540ƒ55000ƒFalseƒ3ƒCombo Bun XaoƒVJ175 - Ha NoiƒNAƒ2158540ƒ1ƒCombo Bun Xaoƒ55,000 VNDƒ55000ƒ5500.00ƒ0ƒ0"
          body["hidPaxItem:-#{current_index}:24:2:0"] = "2ƒNAƒ24ƒ2158052ƒ40000ƒFalseƒ3ƒMi YƒVJ175 - Ha NoiƒNAƒ2158052ƒ1ƒMi Yƒ40,000 VNDƒ40000ƒ4000.00ƒ0ƒ0"
          body["hidPaxItem:-#{current_index}:92:2:0"] = "2ƒNAƒ92ƒ2378594ƒ55000ƒFalseƒ3ƒCombo My YƒVJ175 - Ha NoiƒNAƒ2378594ƒ1ƒCombo My Yƒ55,000 VNDƒ55000ƒ5500.00ƒ0ƒ0"
        end

        agent.post(
          "https://agent.vietjetair.com/AddOns.aspx?lang=vi&st=sl&sesid=",
          body
        )
      end

      def checkout
        agent.post(
          "https://agent.vietjetair.com/Payments.aspx?lang=vi&st=sl&sesid=",
          {
            "__VIEWSTATE" => "",
            "__VIEWSTATEGENERATOR" => "",
            "button" => "3rd",
            "DebugID" => "",
            "SesID" => "",
            "lstPmtType" => "5,PL,0,V,0,0,0",
            "txtCardNo" => "",
            "dlstExpiry" => "2015/11/30",
            "txtCVC" => "",
            "txtCardholder" => "",
            "txtAddr1" => "",
            "txtCity" => "",
            "txtPCode" => "",
            "lstCtry" => "-1",
            "lstProv" => "-1",
            "txtPhone" => ""
          }
        )
      end

      def confirm_info
        agent.post(
          "https://agent.vietjetair.com/Confirm.aspx?lang=vi&st=sl&sesid=",
          {
            "__VIEWSTATE" => "",
            "__VIEWSTATEGENERATOR" => "",
            "DebugID" => "36",
            "button" => "continue",
            "txtPax1_Gender" => "F",
            "txtPax1_LName" => "Pham",
            "txtPax1_FName" => "Thi Minh Chau",
            "chkIAgree" => "on"
          }
        )
      end

      def process
        agent.post(
          "https://agent.vietjetair.com/Processing.aspx?lang=vi&st=sl&sesid=",
          {
            "__VIEWSTATE" => "",
            "__VIEWSTATEGENERATOR" => "",
            "SesID" => "",
            "DebugID" => "36"
          }
        )
      end
    end
  end
end
