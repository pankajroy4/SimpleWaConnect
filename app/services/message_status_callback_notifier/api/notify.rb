module MessageStatusCallbackNotifier
  module Api
    module Notify
      extend self

      def call(message)
        url = build_url(message)

        Request.post(url, request_body(message), request_headers(message))
      end

      private

      def build_url(message)
        message.user.callback_url
      end

      def request_body(message)
        success_response =
          {
            "message_id" => message.id,
            "status" => message.status,
            "message_group" => message.message_group,
            "recipient" => message.customer.phone_number,
          }

        return success_response.to_json unless message.failed?

        return success_response.merge({ error: { message: message.error_text, data: message.response_json } }).as_json
      end

      def request_headers(message)
        {
          "Content-Type" => "application/json",
          "Authorization" => message.user.callback_secret
        }
      end
    end
  end
end
