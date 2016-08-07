FactoryGirl.define do
  factory :passenger do
    order nil
    no 1
    dob "2016-08-07 08:45:15"
    category "MyString"
    depart_lug_weight 1
    return_lug_weight 1
  end
end
