require "flight_formulas"

class JetstarFormulas
  include FlightFormulas

  def format_date(date_str)
    date_str.to_date.strftime("%d/%m/%Y")
  end

  def format_currency(number)
    number_to_currency(number, delimiter: ",", format: "VND %n", precision: 0)
  end

  def get_selected_price_element(page, round, flight_code, price)
    flight_code_square = page.search(".#{round} tr").at("td.flight-code:contains('#{flight_code}')")

    return nil unless flight_code_square

    flight_price_selection = nil

    flight_code_square.parent.search("td.selection").each do |price_selection|
      if price_selection.text.include? format_currency price
        flight_price_selection = price_selection
        break
      end
    end

    flight_price_selection
  end

  def luggage(weight)
    if weight == 0
      "none"
    else
      "BG#{weight}"
    end
  end

  def title_adult(gender_id)
    if gender_id == 1
      "MR"
    else
      "MRS"
    end
  end

  def title_child(gender_id)
    if gender_id == 1
      "MSTR"
    else
      "MISS"
    end
  end
end
