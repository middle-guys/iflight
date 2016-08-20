class Flight < ApplicationRecord
  belongs_to :order, inverse_of: :flights
  belongs_to :plane_category

  enum category: {
    depart: "depart",
    return: "return"
  }
end
