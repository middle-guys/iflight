class Airport < ApplicationRecord

  def airport_info
    "#{self.name_unsigned} (#{self.code})"
  end

end
