class PlaneCategory < ApplicationRecord
  has_many :flights
  enum category: {
    vietjet: "vietjet",
    jetstar: "jetstar",
    vietnam_airline: "vietnam airline"
  }
end
