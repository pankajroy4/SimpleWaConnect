FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
    platform { "whatsapp" }

    after(:build) do |account|
      account.whatsapp_phone_numbers << build(:whatsapp_phone_number, account: account, status: :active)
    end
  end
end
