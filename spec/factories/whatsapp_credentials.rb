FactoryBot.define do
  factory :whatsapp_credential do
    association :account
    access_token { "token123" }
    app_secret { "secret123" }
    webhook_verify_token { "verify123" }
    waba_id_meta { "waba_123" }
  end
end
