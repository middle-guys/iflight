FactoryGirl.define do
  factory :order do
    order_number "MyString"
    user nil
    contact_name "MyString"
    contact_phone "MyString"
    contact_email "MyString"
    contact_gender "MyString"
    adult 1
    child 1
    infant 1
    ori_airport_id 1
    des_airport_id 1
    status "MyString"
    time_expired "2016-08-07 08:33:52"
    price_total "9.99"
  end
end
