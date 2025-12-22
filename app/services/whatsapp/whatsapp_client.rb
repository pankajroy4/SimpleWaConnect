# require "httparty"

# module Whatsapp
#   class WhatsappClient
#     def self.send(payload, account, phone_number_id)
#       number_id = phone_number_id || account.whatsapp_phone_numbers.active.first.phone_number_id

#       HTTParty.post(
#         "https://graph.facebook.com/v23.0/#{number_id}/messages",
#         headers: {
#           "Authorization" => "Bearer #{account.whatsapp_credential.access_token}",
#           "Content-Type": "application/json",
#         },
#         body: payload.to_json,
#       )
#     end
#   end
# end

require "httparty"

module Whatsapp
  class WhatsappClient
    MESSAGE_JOB_LOGGER = Logger.new(Rails.root.join("log/message_jobs.log"))
    MESSAGE_JOB_LOGGER.level = Logger::INFO

    def self.send(payload, account, phone_number_id)
      number_id = phone_number_id || account.whatsapp_phone_numbers.active.first.phone_number_id_meta

      response = HTTParty.post(
        "https://graph.facebook.com/v23.0/#{number_id}/messages",
        headers: {
          "Authorization" => "Bearer #{account.whatsapp_credential.access_token}",
          "Content-Type": "application/json",
        },
        body: payload.to_json,
        timeout: 10,
      )

      unless response.success?
        MESSAGE_JOB_LOGGER.error("[WhatsappClient] API failure | account_id=#{account.id} | phone_number_id=#{number_id} | status=#{response.code} | body=#{response.body}")
      end

      response
    rescue HTTParty::Error => e
      MESSAGE_JOB_LOGGER.error("[WhatsappClient] Network error | account_id=#{account.id} | error=#{e.class} | message=#{e.message}")
      raise
    rescue StandardError => e
      MESSAGE_JOB_LOGGER.error("[WhatsappClient] Unexpected error | account_id=#{account.id} | error=#{e.class} | message=#{e.message}")
      raise
    end
  end
end
