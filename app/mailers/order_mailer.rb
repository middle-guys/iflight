class OrderMailer < ApplicationMailer
  def receipt
    mail(to: 'coder.leo.le@gmail.com', subject: 'Receipt from iFlight')
  end
end
