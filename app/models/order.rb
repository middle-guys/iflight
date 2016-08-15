class Order < ApplicationRecord
  belongs_to :user
  belongs_to :des_airport, foreign_key: :des_airport_id, class_name: "Airport"
  belongs_to :ori_airport, foreign_key: :ori_airport_id, class_name: "Airport"
  has_many :flights
  has_many :passengers

  accepts_nested_attributes_for :passengers

  enum status: [
    :reserving,
    :done,
    :failed,
    :cancelled
  ]

  enum category: [
    :one_way,
    :round_trip
  ]

  def self.generate_order_number
    loop do
      @order_number = SecureRandom.hex(16/4).upcase
      break unless Order.exist?(order_number: @order_number)
    end
    @order_number
  end
end
