module Whatsapp
  class MessageResponse
    ACCOUNT_NOT_REGISTER_ERROR_CODE = 133010
    ACCOUNT_PAYMENT_ERROR_CODE = 131042
    USER_NOT_ON_WHATS_APP_ERROR_CODE = 131026
    APP_INTERNAL_SERVER_ERROR = 500

    ACCONT_LEVEL_ERROR_CODES = [ACCOUNT_NOT_REGISTER_ERROR_CODE, ACCOUNT_PAYMENT_ERROR_CODE]

    def initialize(raw_response)
      @raw_response = raw_response
    end

    def success?
      !failed?
    end

    def wa_message_id
      @raw_response.parsed_response&.dig("messages", 0, "id")
    end

    def success_response
      @raw_response.parsed_response
    end

    def raw_response
      @raw_response
    end

    def message_status
      success_response.dig("messages", 0, "message_status")
    end

    def failed?
      @raw_response["error"].present?
    end

    def error_in_account?
      ACCONT_LEVEL_ERROR_CODES.includes?(error_code)
    end

    def internal_server_error?
      APP_INTERNAL_SERVER_ERROR == error_code
    end

    def error_message
      return nil if !failed?

      @raw_response["error"]["message"]
    end

    def error_code
      return nil if !failed?

      @raw_response["error"]["code"]
    end
  end
end
