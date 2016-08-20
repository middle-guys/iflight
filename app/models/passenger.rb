class Passenger < ApplicationRecord
  belongs_to :order, inverse_of: :passengers

  enum category: {
    adult: "adult",
    child: "child",
    infant: "infant"
  }

  enum gender: {
    male: "male",
    female: "female"
  }
end
