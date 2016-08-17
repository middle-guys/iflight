module FlightsHelper
  def plane_category_name(plane_category)
    if plane_category.vietnam_airlines?
      return "Vietnam Airline"
    elsif plane_category.jetstar?
      return "Jetstar"
    elsif plane_category.vietjet_air?
      return "Vietjet Air"
    else
      return ""
    end
  end
end
