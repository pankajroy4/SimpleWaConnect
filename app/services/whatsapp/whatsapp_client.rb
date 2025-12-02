require "httparty"

module Whatsapp
  class WhatsappClient
    def self.send(payload, account, phone_number_id)
      number_id = phone_number_id || account.whatsapp_phone_numbers.active.first.phone_number_id

      HTTParty.post(
        "https://graph.facebook.com/v23.0/#{number_id}/messages",
        headers: {
          "Authorization" => "Bearer #{account.whatsapp_credential.access_token}",
          "Content-Type": "application/json",
        },
        body: payload.to_json,
      )
    end
  end
end
