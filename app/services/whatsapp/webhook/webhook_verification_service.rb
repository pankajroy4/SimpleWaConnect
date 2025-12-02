class Whatsapp::Webhook::WebhookVerificationService
  def self.call(params)
    mode = params["hub.mode"]
    token = params["hub.verify_token"]
    challenge = params["hub.challenge"]

    return nil if mode.blank? || token.blank? || challenge.blank?

    cred = WhatsappCredential.find_by(webhook_verify_token: token)
    return nil unless cred.present?

    if mode == "subscribe" && ActiveSupport::SecurityUtils.secure_compare(token.to_s, cred.webhook_verify_token.to_s)
      challenge
    else
      nil
    end
  rescue => e
    puts("[WebhookVerificationService] Error: #{e.class} - #{e.message}")
    nil
  end
end
