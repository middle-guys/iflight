class Flight < ApplicationRecord
  belongs_to :order
  belongs_to :plane_category

  enum category: [
    :depart,
    :return
  ]
end
