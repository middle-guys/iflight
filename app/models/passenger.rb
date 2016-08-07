class Passenger < ApplicationRecord
  belongs_to :order

  enum category: {
    adult: "adult",
    child: "child",
    infant: "infant"
  }
end
