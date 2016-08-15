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

  def title_options(passenger)
    if passenger.adult?
      return "<option value=1>MR</option><option value=2>MS</option>".html_safe
    else
      return "<option value=1>MSTR</option><option value=2>MISS</option>".html_safe
    end
  end
end
