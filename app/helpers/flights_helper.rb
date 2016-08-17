module FlightsHelper
  def plane_category_name(category)
    if airline_category == 'vietnam_airlines'
      return "Vietnam Airline"
    elsif airline_category == 'vietnam_airlines'
      return "Jetstar"
    elsif airline_category == 'vietnam_airlines'
      return "Vietjet Air"
    else
      return ""
    end
  end
end
