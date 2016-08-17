require "flight_formulas"

class VietnamAirlinesFormulas
  include FlightFormulas

  def format_date(date_str)
    date_str.to_date.strftime("%Y-%m-%d")
  end

  def format_currency(number)
    number_to_currency(number, delimiter: ",", format: "%n", precision: 0)
  end
end
