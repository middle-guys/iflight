module MailerHelper
  def format_date(date)
    date.strftime('%d/%m/%Y')
  end

  def format_time(date)
    date.strftime("%H:%M")
  end

  def plane_category_logo_name(plane_category)
    if plane_category.vietnam_airlines?
      return "vna.png"
    elsif plane_category.jetstar?
      return "jet.png"
    elsif plane_category.vietjet_air?
      return "vjet.png"
    else
      return ""
    end
  end

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

  def title_name(passenger)
    if passenger.adult?
      if passenger.gender?
        return "MR"
      else
        return "MS"
      end
    else
      if passenger.gender?
        return "MSTR"
      else
        return "MISS"
      end
    end
  end
end