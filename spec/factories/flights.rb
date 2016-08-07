FactoryGirl.define do
  factory :flight do
    order nil
    category "MyString"
    plane_category nil
    time_depart "2016-08-07 08:42:54"
    time_arrive "2016-08-07 08:42:54"
    code_flight "MyString"
    code_book "MyString"
    price_web "9.99"
    price_total "9.99"
  end
end
