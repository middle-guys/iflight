class PlaneCategory < ApplicationRecord
  has_many :flights

  enum category: [
    :vietjet_air,
    :jetstar,
    :vietnam_airlines
  ]
end
