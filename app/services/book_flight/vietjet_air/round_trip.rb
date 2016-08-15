module BookFlight
  module VietjetAir
    class RoundTrip < VietjetAirFormulas
      attr_accessor :agent, :itinerary, :depart_flight, :return_flight, :passengers, :contact, :adult_passengers, :child_passengers, :infant_passengers

      def initialize(agent, params)
        @agent = agent
        @itinerary = params[:itinerary]
        @depart_flight = params[:depart_flight]
        @return_flight = params[:return_flight]
        @passengers = params[:passengers]
        @contact = params[:contact]
        @adult_passengers = passengers.select{ |x| x[:category] == 1 }
        @child_passengers = passengers.select{ |x| x[:category] == 2 }
        @infant_passengers = passengers.select{ |x| x[:category] == 3 }
      end

      def call
        select_price_page = search

        depart_selected_price_element = get_selected_price_element(select_price_page, "toDepDiv", depart_flight[:flight_code], depart_flight[:price_no_fee])

        return 404 unless depart_selected_price_element

        return_selected_price_element = get_selected_price_element(select_price_page, "toRetDiv", return_flight[:flight_code], return_flight[:price_no_fee])

        return 404 unless return_selected_price_element

        fill_info_page = select_price(depart_selected_price_element, return_selected_price_element)

        checkout_page = fill_info

        File.open("out.html", "wb") do |f|
          f.write checkout_page.body
          f.close
        end

        # checkout_page = fill_info

        # reservation_page = checkout

        # {
        #   reservation_code: reservation_page.at("#booking-data booking")["pnr"],
        #   holding_date: reservation_page.at("#booking-data booking")["holddateutc"]
        # }
      end

      def search
        agent.post(
          "https://agent.vietjetair.com/ViewFlights.aspx?lang=vi&st=sl&sesid=",
          {
            "__VIEWSTATE" => "",
            "__VIEWSTATEGENERATOR" => "",
            "SesID" => "",
            "DebugID" => "10",
            "button" => "vfto",
            "dlstDepDate_Day" => format_day(itinerary[:depart_date]),
            "dlstDepDate_Month" => format_year_month(itinerary[:depart_date]),
            "dlstRetDate_Day" => format_day(itinerary[:return_date]),
            "dlstRetDate_Month" => format_year_month(itinerary[:return_date]),
            "lstDepDateRange" => "0",
            "lstRetDateRange" => "0",
            "chkRoundTrip" => "on",
            "lstOrigAP" => itinerary[:ori_airport][:code],
            "lstDestAP" => itinerary[:des_airport][:code],
            "departure1" => format_date(itinerary[:depart_date]),
            "departTime1" => "0000",
            "departure2" => format_date(itinerary[:return_date]),
            "departTime2" => "0000",
            "lstLvlService" => "1",
            "lstResCurrency" => "VND",
            "txtNumAdults" => itinerary[:adult_num],
            "txtNumChildren" => itinerary[:child_num],
            "txtNumInfants" => itinerary[:infant_num],
            "lstCompanyList" => "3184ƒCTY TNHH TM&DV DL BAO GIA TRAN (SUB 2)",
            "txtPONumber" => ""
          }
        )
      end

      def select_price(depart_selected_price_element, return_selected_price_element)
        agent.post(
          "https://agent.vietjetair.com//TravelOptions.aspx?lang=vi&st=sl&sesid=",
          "__VIEWSTATE" => "",
          "__VIEWSTATEGENERATOR" => "",
          "button" => "continue",
          "SesID" => "",
          "DebugID" => "10",
          "PN" => "",
          "RPN" => "",
          "gridTravelOptDep" => travel_info(depart_selected_price_element),
          "gridTravelOptRet" => travel_info(return_selected_price_element)
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

      def checkout

      end
    end
  end
end
