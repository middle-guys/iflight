class Passenger < ApplicationRecord
  belongs_to :order, inverse_of: :passengers

  enum category: [
    :adult,
    :child,
    :infant
  ]

  enum gender: [
    :male,
    :female
  ]
end
