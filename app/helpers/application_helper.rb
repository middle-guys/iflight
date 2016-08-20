module ApplicationHelper
  def format_currency(price)
    number_to_currency(price, precision: 0, unit: "VND", delimiter: ",", format: "%n %u")
  end
end
