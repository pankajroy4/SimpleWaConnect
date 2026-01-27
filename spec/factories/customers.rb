FactoryBot.define do
  factory :customer do
    association :account
    name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
    unread_count { 0 }
  end
end
