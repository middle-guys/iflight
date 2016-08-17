module DateHelper
  def format_date(date)
    date.strftime('%d/%m/%Y')
  end

  def format_time(date)
    date.strftime("%H:%M")
  end
end