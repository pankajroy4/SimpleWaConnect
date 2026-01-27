FactoryBot.define do
  factory :user do
    association :account
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    role { :admin }
  end
end
