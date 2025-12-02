class Whatsapp::Webhook::SignatureVerifierService
  def self.call(payload, signature_header, phone_number_id, waba_id)
    return false if signature_header.blank? || payload.blank? || phone_number_id.blank? || waba_id.blank?

    begin
      account = Account
        .joins(:whatsapp_credential, :whatsapp_phone_numbers)
        .find_by(
          whatsapp_credentials: { waba_id: waba_id },
          whatsapp_phone_numbers: {
            phone_number_id: phone_number_id,
            status: WhatsappPhoneNumber.statuses[:active],
          },
        )

      unless account
        # WHATSAPP_LOGGER.warn("[SignatureVerifierService] No account found for phone_number_id=#{phone_number_id}")
        return false
      end

      secret = account.whatsapp_credential.app_secret
      if secret.blank?
        # WHATSAPP_LOGGER.warn("[SignatureVerifierService] Missing app_secret for account #{account.id}")
        return false
      end

      scheme, signature = signature_header.split("=", 2)
      return false unless scheme == "sha256" && signature.present?

      digest = OpenSSL::HMAC.hexdigest("sha256", secret, payload)

      # constant-time comparison to prevent timing attacks
      ActiveSupport::SecurityUtils.secure_compare(digest, signature)
    rescue => e
      # WHATSAPP_LOGGER.error("[SignatureVerifierService] Error: #{e.class} - #{e.message}")
      false
    end
  end
end
