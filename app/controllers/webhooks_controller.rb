class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature, only: [:receive]

  def verify
    if Whatsapp::Webhook::WebhookVerificationService.call(params)
      render plain: params["hub.challenge"], status: :ok
    else
      head :forbidden
    end
  end

  def receive
    Whatsapp::ProcessWebhookJob.perform_later(request.raw_post)
    head :ok
  end

  private

  def verify_signature
    phone_number_id, waba_id = extract_phone_number_id(request.raw_post)

    valid = Whatsapp::Webhook::SignatureVerifierService.call(
      request.raw_post,
      request.headers["X-Hub-Signature-256"],
      phone_number_id,
      waba_id,
    )

    head :forbidden unless valid
  end

  def extract_phone_number_id(raw_payload)
    json = JSON.parse(raw_payload) rescue {}
    waba_id = json.dig("entry", 0, "id")
    phone_number_id = json.dig("entry", 0, "changes", 0, "value", "metadata", "phone_number_id")
    [phone_number_id, waba_id]
  end
end
