# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def receipt
    OrderMailer.receipt(Order.last)
  end
end
