module DateHelper
  def format_date(date)
    date.strftime("%d/%m/%Y")
  end

  def format_time(date)
    date.strftime("%H:%M")
  end

  def format_date_time(date)
    date.strftime("%H:%M %d/%m/%Y")
  end

  def format_date_month_str(date)
    date.strftime("%b %m, %Y")
  end
end