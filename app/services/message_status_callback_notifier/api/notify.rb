module MessageStatusCallbackNotifier
  module Api
    module Notify
      extend self

      def call(message)
        url, secret = build_url_and_secret(message)
        return unless url.present?

        body = request_body(message)
        timestamp = Time.now.to_i.to_s
        signature = generate_signature(secret, timestamp, body)

        Request.post(url, body, request_headers(signature, timestamp))
      end

      private

      def build_url_and_secret(message)
        url = if message.user&.callback_url.present?
            message.user.callback_url
          else
            message.account&.users&.where.not(callback_url: [nil, ""])&.pick(:callback_url)
          end

        secret = if message.user&.callback_secret.present?
            message.user&.callback_secret
          else
            message.account&.users&.where.not(callback_secret: [nil, ""])&.pick(:callback_secret)
          end

        [url, secret]
      end

      def request_body(message)
        {
          event: event_type_for(message),
          data: event_payload_for(message),
        }.to_json
      end

      def event_type_for(message)
        message.incoming? ? "message.incoming" : "message.status"
      end

      def event_payload_for(message)
        if message.incoming?
          {
            message_id: message.id,
            message_type: message.message_type,
            from: message.customer.phone_number,
            wa_mobile_number_id_meta: message.payload["sender_phone_number_id"],
            kind: message.payload&.dig("kind"),
            content: message.payload,
            received_at: message.created_at,
          }
        else
          payload = {
            message_id: message.id,
            status: message.status,
            message_group: message.message_group,
            recipient: message.customer.phone_number,
            wa_mobile_number_id_meta: message.payload["sender_phone_number_id"],
          }

          return payload unless message.failed?

          payload.merge(
            error: {
              message: message.error_text,
              data: message.response_json,
            },
          )
        end
      end

      def request_headers(signature, timestamp)
        {
          "Content-Type" => "application/json",
          "X-Signature" => "sha256=#{signature}",
          "X-Timestamp" => timestamp,
        }
      end

      def generate_signature(secret, timestamp, body)
        data = "#{timestamp}.#{body}"
        digest = OpenSSL::HMAC.digest("SHA256", secret, data)
        Base64.strict_encode64(digest)
      end
    end
  end
end


=begin
NOTE: Receving application should verify the signature of webhook like below:
======================================================================================================

  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_webhook_signature!

    def receive
      payload = JSON.parse(request.raw_post)

      # safe to process webhook now
      render json: { status: "ok" }
    end

    private

    def verify_webhook_signature!
      raw_body = request.raw_post
      timestamp = request.headers["X-Timestamp"]
      received_signature = request.headers["X-Signature"]&.split("=")&.last
      secret = webhook_secret

      unless valid_timestamp?(timestamp) && valid_signature?(secret, timestamp, raw_body, received_signature)
        render json: { error: "Invalid signature" }, status: :unauthorized
      end
    end

    def webhook_secret
      ENV["WEBHOOK_SECRET"]
    end

    def valid_signature?(secret, timestamp, body, received_signature)
      return false if secret.blank? || received_signature.blank?

      data = "#{timestamp}.#{body}"
      expected = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", secret, data))

      ActiveSupport::SecurityUtils.secure_compare(expected, received_signature)
    end

    def valid_timestamp?(timestamp)
      return false if timestamp.blank?

      request_time = Time.at(timestamp.to_i)
      (Time.current - request_time).abs < 5.minutes
    end
  end

======================================================================================================
=end