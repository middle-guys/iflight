module PassengersHelper
  def category_name(passenger)
    if passenger.adult?
      return "Adult"
    elsif passenger.child?
      return "Child"
    elsif passenger.infant?
      return "Infant"
    else
      return ""
    end
  end

  def title_options(is_adult)
    if is_adult
      return "<option value='male'>MR</option><option value='female'>MS</option>".html_safe
    else
      return "<option value='male'>MSTR</option><option value='female'>MISS</option>".html_safe
    end
  end
end
