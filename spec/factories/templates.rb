FactoryBot.define do
  factory :template do
    association :account
    name { "order_update" }
    language_code { "en_US" }
    media_type { "text" }
    body_variables { ["name", "order_id"] }
  end
end
