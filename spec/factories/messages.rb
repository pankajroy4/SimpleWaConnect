FactoryBot.define do
  factory :message do
    association :account
    association :customer
    direction { :outgoing }
    message_type { :non_template_message }
    status { :queued }
    bulk_created { false }

    trait :incoming do
      direction { :incoming }
    end

    trait :template_message do
      message_type { :template_message }
      association :template
    end
  end
end
