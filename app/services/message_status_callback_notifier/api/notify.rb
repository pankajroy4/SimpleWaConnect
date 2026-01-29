module MessageStatusCallbackNotifier
  module Api
    module Notify
      extend self

      def call(message)
        url, secret = build_url_and_secret(message)
        return unless url.present?

        Request.post(url, request_body(message), request_headers(secret))
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

      def request_headers(secret)
        # we can add HMAC signature verification instead of passing raw secret in Authorization header
        {
          "Content-Type" => "application/json",
          "Authorization" => secret,
        }
      end
    end
  end
end
