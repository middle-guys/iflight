require "flight_formulas"

class JetstarFormulas
  include FlightFormulas

  def format_date(date_str)
    date_str.to_date.strftime("%d/%m/%Y")
  end

  def format_currency(number)
    number_to_currency(number, delimiter: ",", format: "VND %n", precision: 0)
  end
end
