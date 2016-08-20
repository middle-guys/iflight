class PlaneCategory < ApplicationRecord
  has_many :flights

  enum category: {
    vietjet_air: "vietjet_air",
    jetstar: "jetstar",
    vietnam_airlines: "vietnam_airlines"
  }
end
