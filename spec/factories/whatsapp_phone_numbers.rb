FactoryBot.define do
  factory :whatsapp_phone_number do
    association :account
    phone_number_id_meta { Faker::Number.unique.number(digits: 10) }
    display_number { Faker::PhoneNumber.cell_phone }
    country_code { "91" }
    status { :active }
  end
end
