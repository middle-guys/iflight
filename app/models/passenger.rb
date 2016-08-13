class Passenger < ApplicationRecord
  belongs_to :order

  enum category: [
    :adult,
    :child,
    :infant
  ]
end
